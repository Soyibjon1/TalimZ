import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/websocket_ai_service.dart';
import '../../core/providers/app_provider.dart';
import '../../core/widgets/connection_status_widget.dart';
import '../../core/widgets/logo_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  // AI va Voice xizmatlari
  final VoiceService _voiceService = VoiceServiceProvider.instance;
  bool _isTyping = false;
  bool _isVoiceMode = false;
  String _currentSubject = 'Umumiy';
  
  // Animation controllers
  late AnimationController _micAnimationController;
  late AnimationController _waveAnimationController;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
    _loadInitialMessages();
  }

  void _initializeServices() async {
    // Gemini API kalitini olish (haqiqiy kalitni .env fayliga qo'ying)
    GeminiService.initialize('YOUR_GEMINI_API_KEY_HERE'); // .env faylidagi GEMINI_API_KEY dan oling
    
    // Voice service ni ishga tushirish
    await _voiceService.initialize();
    
    // Voice service holatlarini eshitish
    _voiceService.stateStream.listen(_onVoiceStateChanged);
    _voiceService.transcriptionStream.listen(_onTranscriptionReceived);
  }

  void _setupAnimations() {
    _micAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _loadInitialMessages() {
    setState(() {
      _messages.clear();
      _messages.addAll([
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Assalomu alaykum! Men sizning AI mentoringiz TalimZ-man. Bugun qaysi fandan yordam kerak?',
          isAi: true,
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    _waveAnimationController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Voice service event handlers
  void _onVoiceStateChanged(VoiceState state) {
    setState(() {
      switch (state) {
        case VoiceState.listening:
          _micAnimationController.repeat();
          break;
        case VoiceState.processing:
          _micAnimationController.stop();
          _isTyping = true;
          break;
        case VoiceState.speaking:
          _waveAnimationController.repeat();
          break;
        case VoiceState.idle:
          _micAnimationController.stop();
          _waveAnimationController.stop();
          _isTyping = false;
          break;
        case VoiceState.error:
          _micAnimationController.stop();
          _waveAnimationController.stop();
          _isTyping = false;
          _showErrorSnackbar('Ovozli xizmatda xatolik yuz berdi');
          break;
      }
    });
  }

  void _onTranscriptionReceived(String transcription) {
    if (transcription.isNotEmpty && transcription != _controller.text) {
      setState(() {
        _controller.text = transcription;
      });
    }
    
    // Agar final natija bo'lsa va yetarli matn bo'lsa, yuboramiz
    if (transcription.length > 5 && !_voiceService.isListening) {
      _sendVoiceMessage(transcription);
    }
  }

  static const List<String> _quickReplies = [
    'Test yubor', // WebSocket test uchun
    'Tushuntirib ber',
    'Misol keltir',  
    'Vizualizatsiya',
    'Qoida eslatib ber',
  ];

  static const List<String> _subjects = [
    'Umumiy',
    'Matematika',
    'Fizika', 
    'Kimyo',
    'Biologiya',
    'Tarix',
    'Adabiyot',
  ];

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isAi: false,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      // Gemini dan javob olish
      final response = await GeminiService.instance.sendMessage(
        text,
        subject: _currentSubject,
        chatHistory: _messages,
      );

      final aiMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response,
        isAi: true,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );

      setState(() {
        _messages.add(aiMsg);
        _isTyping = false;
      });

      _scrollToBottom();
      
      // Agar ovozli rejimda bo'lsa, javobni o'qish
      if (_isVoiceMode) {
        await _voiceService.speak(response);
      }

    } catch (e) {
      setState(() {
        _isTyping = false;
      });
      _showErrorSnackbar('Javob olishda xatolik yuz berdi');
    }
  }

  void _sendVoiceMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Voice message yuborish
    _sendMessage(text);
  }

  void _toggleVoiceMode() async {
    setState(() {
      _isVoiceMode = !_isVoiceMode;
    });

    if (_isVoiceMode) {
      // Voice mode yoqish
      if (_voiceService.isInitialized) {
        await _voiceService.speak('Ovozli rejim yoqildi. Endi gapirishingiz mumkin.');
      }
    } else {
      // Voice mode o'chirish  
      await _voiceService.stopListening();
      await _voiceService.stopSpeaking();
    }
  }

  void _startListening() async {
    if (!_voiceService.isInitialized) {
      _showErrorSnackbar('Ovozli xizmat tayyor emas');
      return;
    }

    await _voiceService.startListening();
  }

  void _stopListening() async {
    await _voiceService.stopListening();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSubjectSelector(),
          Expanded(child: _buildMessageList()),
          if (_isVoiceMode) _buildVoiceInterface(),
          if (!_isVoiceMode) _buildQuickReplies(),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          SmallLogoWidget(
            size: 36, 
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ta'limZ AI",
                style: AppTextStyles.h3.copyWith(color: Colors.white),
              ),
              StreamBuilder<VoiceState>(
                stream: _voiceService.stateStream,
                builder: (context, snapshot) {
                  String status = 'Sizni eshitmoqda...';
                  switch (snapshot.data) {
                    case VoiceState.listening:
                      status = 'Eshitmoqda...';
                      break;
                    case VoiceState.processing:
                      status = 'Qayta ishlamoqda...';
                      break;
                    case VoiceState.speaking:
                      status = 'Gapirmoqda...';
                      break;
                    case VoiceState.error:
                      status = 'Xatolik yuz berdi';
                      break;
                    default:
                      status = 'Tayyor';
                  }
                  return Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Manual test tugmasi (debug uchun)
        IconButton(
          onPressed: () async {
            final wsService = WebSocketAiService();
            final messenger = ScaffoldMessenger.of(context);
            
            await wsService.manualConnectionTest();
            
            if (mounted) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Connection test console da ko\'ring'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.bug_report, color: Colors.white70),
          tooltip: 'Debug Test',
        ),
        const ConnectionStatusWidget(),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _toggleVoiceMode,
          icon: Icon(
            _isVoiceMode ? Icons.voice_chat : Icons.chat_bubble_outline,
            color: _isVoiceMode ? AppColors.accent : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final isSelected = subject == _currentSubject;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentSubject = subject;
                });
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAi = message.isAi;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) _buildAiAvatar(),
          if (isAi) const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAi ? Colors.grey.shade100 : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAi ? 4 : 20),
                  bottomRight: Radius.circular(isAi ? 20 : 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isAi ? Colors.grey.shade800 : Colors.white,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: (isAi ? Colors.grey.shade500 : Colors.white.withValues(alpha: 0.7)),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isAi) const SizedBox(width: 12),
          if (!isAi) _buildUserAvatar(),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildAiAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.psychology, color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.accent,
          child: Text(
            provider.currentUser.name.isNotEmpty
                ? provider.currentUser.name[0].toUpperCase()
                : 'O',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _buildAiAvatar(),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 4),
                    child: Icon(
                      Icons.circle,
                      size: 8,
                      color: Colors.grey.shade400,
                    ).animate(onPlay: (controller) => controller.repeat())
                        .scale(delay: (i * 200).ms, duration: 600.ms)
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceInterface() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.accent.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          StreamBuilder<String>(
            stream: _voiceService.transcriptionStream,
            builder: (context, snapshot) {
              return Text(
                snapshot.data?.isNotEmpty == true 
                    ? snapshot.data!
                    : 'Gapiring...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontStyle: snapshot.data?.isEmpty == true ? FontStyle.italic : FontStyle.normal,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoiceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return StreamBuilder<VoiceState>(
      stream: _voiceService.stateStream,
      builder: (context, snapshot) {
        final state = snapshot.data ?? VoiceState.idle;
        Color buttonColor = AppColors.primary;
        IconData icon = Icons.mic;
        VoidCallback? onPressed = _startListening;

        switch (state) {
          case VoiceState.listening:
            buttonColor = Colors.red;
            icon = Icons.mic;
            onPressed = _stopListening;
            break;
          case VoiceState.processing:
            buttonColor = Colors.orange;
            icon = Icons.hourglass_empty;
            onPressed = null;
            break;
          case VoiceState.speaking:
            buttonColor = AppColors.accent;
            icon = Icons.volume_up;
            onPressed = () => _voiceService.stopSpeaking();
            break;
          case VoiceState.error:
            buttonColor = Colors.red;
            icon = Icons.error_outline;
            onPressed = () => _voiceService.initialize();
            break;
          default:
            break;
        }

        return GestureDetector(
          onTap: onPressed,
          child: AnimatedBuilder(
            animation: _micAnimationController,
            builder: (context, child) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withValues(alpha: 0.3),
                      blurRadius: state == VoiceState.listening ? 20 : 10,
                      spreadRadius: state == VoiceState.listening ? 5 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_quickReplies[index]),
              onPressed: () => _sendMessage(_quickReplies[index]),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    if (_isVoiceMode) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Savolingizni yozing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_controller.text),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Hozir';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} soat oldin';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}