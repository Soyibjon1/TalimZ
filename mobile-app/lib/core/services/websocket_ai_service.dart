import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/models.dart';
import '../config/websocket_config.dart';

enum WebSocketConnectionState { disconnected, connecting, connected, failed, hostNotFound }

/// Python AI server bilan WebSocket orqali aloqa qilish xizmati
class WebSocketAiService {
  static final WebSocketAiService _instance = WebSocketAiService._internal();
  factory WebSocketAiService() => _instance;
  WebSocketAiService._internal();

  static int _currentUrlIndex = 0;
  static int _retryAttempts = 0;
  static int _hostNotFoundRetries = 0;
  static DateTime? _lastHostNotFoundTime;
  
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();
  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  Timer? _reconnectTimer;
  String? _lastError;
  
  // Response kutish uchun
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  int _requestCounter = 0;

  Stream<Map<String, dynamic>> get messages => _controller.stream;
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;
  WebSocketConnectionState get connectionState => _connectionState;
  String? get lastError => _lastError;

  /// Server bilan ulanishni boshlash
  Future<void> connect() async {
    if (_connectionState == WebSocketConnectionState.connecting) {
      debugPrint('⏳ Ulanish jarayoni allaqachon davom etmoqda');
      return;
    }

    // Host not found xatoligi uchun cooldown tekshirish
    if (_connectionState == WebSocketConnectionState.hostNotFound && 
        _lastHostNotFoundTime != null &&
        DateTime.now().difference(_lastHostNotFoundTime!) < WebSocketConfig.hostNotFoundCooldown) {
      final remainingTime = WebSocketConfig.hostNotFoundCooldown - 
          DateTime.now().difference(_lastHostNotFoundTime!);
      debugPrint('❄️ Host not found cooldown: ${remainingTime.inMinutes} daqiqa qoldi');
      return;
    }

    _connectionState = WebSocketConnectionState.connecting;
    _reconnectTimer?.cancel();
    
    final currentUrl = WebSocketConfig.urls[_currentUrlIndex];
    
    try {
      debugPrint('🔄 Ulanish urinishi: $currentUrl (${_currentUrlIndex + 1}/${WebSocketConfig.urls.length})');
      
      final uri = Uri.parse(currentUrl);
      _channel = WebSocketChannel.connect(
        uri,
        protocols: ['websocket'],
      );
      
      // Connection timeout
      final connectionTimer = Timer(WebSocketConfig.connectionTimeout, () {
        if (_connectionState == WebSocketConnectionState.connecting) {
          debugPrint('⏰ Connection timeout: $currentUrl');
          _channel?.sink.close();
          _handleConnectionError('Connection timeout');
        }
      });
      
      _channel!.stream.listen(
        (data) {
          connectionTimer.cancel();
          if (_connectionState != WebSocketConnectionState.connected) {
            _connectionState = WebSocketConnectionState.connected;
            _retryAttempts = 0;
            _hostNotFoundRetries = 0;
            _lastError = null;
            debugPrint('✅ WebSocket ulanish muvaffaqiyatli: $currentUrl');
          }
          
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          _handleResponse(decoded);
        },
        onError: (error) {
          connectionTimer.cancel();
          debugPrint('❌ WebSocket xatolik ($currentUrl): $error');
          _handleConnectionError(error.toString());
        },
        onDone: () {
          connectionTimer.cancel();
          debugPrint('🔌 WebSocket ulanish tugadi ($currentUrl)');
          if (_connectionState == WebSocketConnectionState.connected) {
            _handleConnectionError('Connection closed unexpectedly');
          }
        },
      );
      
    } catch (e) {
      debugPrint('❌ WebSocket ulanish xatoligi ($currentUrl): $e');
      _handleConnectionError(e.toString());
    }
  }

  /// Ulanish xatoliklarini boshqarish
  void _handleConnectionError(String error) {
    _lastError = error;
    _connectionState = WebSocketConnectionState.failed;
    
    // Host not found xatoligini tekshirish
    if (_isHostNotFoundError(error)) {
      _hostNotFoundRetries++;
      if (_hostNotFoundRetries >= WebSocketConfig.maxHostNotFoundRetries) {
        _connectionState = WebSocketConnectionState.hostNotFound;
        _lastHostNotFoundTime = DateTime.now();
        debugPrint('🚫 Host topilmadi: $error');
        debugPrint('❄️ ${WebSocketConfig.hostNotFoundCooldown.inMinutes} daqiqa cooldown boshlandi');
        return;
      }
    }
    
    _tryNextUrl();
  }

  /// Host not found xatoligini aniqlash
  bool _isHostNotFoundError(String error) {
    final hostNotFoundPatterns = [
      'Failed host lookup',
      'No address associated with hostname',
      'errno = 7',
      'SocketException',
      'Name or service not known',
    ];
    
    return hostNotFoundPatterns.any((pattern) => 
        error.toLowerCase().contains(pattern.toLowerCase()));
  }

  /// Keyingi URL ni sinab ko'rish
  void _tryNextUrl() {
    _retryAttempts++;
    
    if (_retryAttempts >= WebSocketConfig.maxRetryAttempts) {
      // Barcha URL-lar sinab ko'rildi, keyingi URL-ga o'tish
      _currentUrlIndex = (_currentUrlIndex + 1) % WebSocketConfig.urls.length;
      _retryAttempts = 0;
      
      if (_currentUrlIndex == 0) {
        // Barcha URL-lar muvaffaqiyatsiz, katta pause
        debugPrint('💔 Barcha URL-lar muvaffaqiyatsiz, ${WebSocketConfig.retryDelay.inSeconds} soniyadan keyin qayta urinish...');
        _connectionState = WebSocketConnectionState.failed;
        _scheduleReconnect();
        return;
      }
    }
    
    debugPrint('🔄 Keyingi urinish ${WebSocketConfig.retryDelay.inSeconds} soniyadan keyin...');
    _scheduleReconnect();
  }

  /// Qayta ulanishni rejalashtirish
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(WebSocketConfig.retryDelay, () => connect());
  }

  /// Ulanishni qayta boshlash (manual)
  Future<void> reconnect() async {
    debugPrint('🔄 Manual qayta ulanish...');
    _connectionState = WebSocketConnectionState.disconnected;
    _retryAttempts = 0;
    _currentUrlIndex = 0;
    await connect();
  }

  /// Host not found cooldown-ni tozalash
  void clearHostNotFoundCooldown() {
    _lastHostNotFoundTime = null;
    _hostNotFoundRetries = 0;
    _connectionState = WebSocketConnectionState.disconnected;
    debugPrint('🔄 Host not found cooldown tozalandi');
  }

  /// Javoblarni qayta ishlash
  void _handleResponse(Map<String, dynamic> response) {
    debugPrint('📥 WebSocket javob olindi: $response');
    _controller.add(response);
    
    // Agar request_id mavjud bo'lsa, kutilayotgan javobga berish
    final requestId = response['request_id'] as String?;
    if (requestId != null && _pendingRequests.containsKey(requestId)) {
      debugPrint('✅ Request $requestId uchun javob topildi');
      _pendingRequests[requestId]!.complete(response);
      _pendingRequests.remove(requestId);
    } else {
      debugPrint('⚠️ Request ID topilmadi yoki kutilmagan javob: $requestId');
    }
  }

  /// Connection holatini test qilish
  Future<bool> testConnection() async {
    if (!isConnected || _channel == null) {
      debugPrint('❌ Connection test: Ulanish yo\'q');
      return false;
    }

    try {
      final requestId = 'test_${++_requestCounter}';
      final completer = Completer<Map<String, dynamic>>();
      _pendingRequests[requestId] = completer;

      final payload = {
        'type': 'status',
        'request_id': requestId,
        'data': {}
      };

      debugPrint('🔍 Connection test yuborilmoqda...');
      _channel?.sink.add(jsonEncode(payload));

      final response = await completer.future.timeout(
        WebSocketConfig.responseTimeout,
        onTimeout: () {
          debugPrint('❌ Connection test timeout');
          _pendingRequests.remove(requestId);
          return <String, dynamic>{'error': 'timeout'};
        },
      );

      final success = response['data']?['status'] == 'active';
      debugPrint(success ? '✅ Connection test muvaffaqiyatli' : '❌ Connection test muvaffaqiyatsiz');
      return success;

    } catch (e) {
      debugPrint('❌ Connection test xatoligi: $e');
      return false;
    }
  }

  /// Connection holati haqida ma'lumot
  Map<String, dynamic> getConnectionInfo() {
    return {
      'state': _connectionState.name,
      'currentUrl': _currentUrlIndex < WebSocketConfig.urls.length 
          ? WebSocketConfig.urls[_currentUrlIndex] : null,
      'retryAttempts': _retryAttempts,
      'hostNotFoundRetries': _hostNotFoundRetries,
      'lastError': _lastError,
      'cooldownRemaining': _lastHostNotFoundTime != null 
          ? WebSocketConfig.hostNotFoundCooldown - DateTime.now().difference(_lastHostNotFoundTime!)
          : null,
    };
  }

  /// Chat xabarini yuborish va javob kutish
  Future<String> sendChatMessage(String message, {
    String? subject,
    String? context,
    List<ChatMessage>? chatHistory,
  }) async {
    if (!isConnected || _channel == null) {
      final errorMsg = _connectionState == WebSocketConnectionState.hostNotFound 
          ? 'AI server topilmadi. URL manzilini tekshiring.' 
          : 'AI server bilan aloqa yo\'q';
      debugPrint('❌ WebSocket: $errorMsg');
      throw Exception(errorMsg);
    }

    debugPrint('📤 WebSocket orqali xabar yuborilmoqda: $message');

    final requestId = 'chat_${++_requestCounter}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    // Chat xabari formatini tayyorlash
    final payload = {
      'type': 'chat',
      'request_id': requestId,
      'data': {
        'message': message,
        'subject': subject,
        'context': context,
        'history': chatHistory?.map((msg) => {
          'role': msg.isAi ? 'assistant' : 'user',
          'content': msg.content,
          'timestamp': msg.timestamp.toIso8601String(),
        }).toList(),
      }
    };

    debugPrint('📤 Payload: ${jsonEncode(payload)}');
    
    try {
      _channel?.sink.add(jsonEncode(payload));
      debugPrint('✅ Xabar yuborildi, javob kutilmoqda...');
    } catch (e) {
      debugPrint('❌ Xabar yuborishda xatolik: $e');
      _pendingRequests.remove(requestId);
      throw Exception('Xabar yuborib bo\'lmadi: $e');
    }

    try {
      final response = await completer.future.timeout(
        WebSocketConfig.responseTimeout,
        onTimeout: () {
          debugPrint('⏰ WebSocket javob timeout');
          _pendingRequests.remove(requestId);
          throw TimeoutException('AI javob berish vaqti tugadi');
        },
      );

      return response['data']?['response'] ?? 'Javob olinmadi';
    } catch (e) {
      _pendingRequests.remove(requestId);
      throw Exception('AI xabar yuborishda xatolik: $e');
    }
  }

  /// Quiz tahlili uchun xabar yuborish
  Future<TalentAnalysis> analyzeQuiz({
    required List<QuestionResult> results,
    required String subject,
    required String topic,
    required int timeSpentSeconds,
  }) async {
    if (!isConnected) {
      throw Exception(_connectionState == WebSocketConnectionState.hostNotFound 
          ? 'AI server topilmadi. URL manzilini tekshiring.'
          : 'AI server bilan aloqa yo\'q');
    }

    final requestId = 'analysis_${++_requestCounter}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    // Quiz tahlili formatini tayyorlash
    final payload = {
      'type': 'analyze_quiz',
      'request_id': requestId,
      'data': {
        'subject': subject,
        'topic': topic,
        'time_spent': timeSpentSeconds,
        'total_questions': results.length,
        'correct_answers': results.where((r) => r.isCorrect).length,
        'questions': results.map((r) => {
          'question_id': r.questionId,
          'is_correct': r.isCorrect,
          'time_spent': r.timeSpentSeconds,
          'selected_answer': r.selectedAnswer,
          'correct_answer': r.correctAnswer,
        }).toList(),
      }
    };

    _channel?.sink.add(jsonEncode(payload));

    try {
      final response = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw TimeoutException('AI tahlil vaqti tugadi');
        },
      );

      return _parseAnalysisResponse(response['data'] ?? {});
    } catch (e) {
      _pendingRequests.remove(requestId);
      throw Exception('AI tahlil xatoligi: $e');
    }
  }

  /// Ovozli suhbat uchun qisqa javob
  Future<String> getVoiceResponse(String message, {String? subject}) async {
    if (!isConnected) {
      throw Exception(_connectionState == WebSocketConnectionState.hostNotFound 
          ? 'AI server topilmadi. URL manzilini tekshiring.'
          : 'AI server bilan aloqa yo\'q');
    }

    final requestId = 'voice_${++_requestCounter}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    final payload = {
      'type': 'voice_chat',
      'request_id': requestId,
      'data': {
        'message': message,
        'subject': subject,
        'max_length': 50, // Qisqa javob uchun
      }
    };

    _channel?.sink.add(jsonEncode(payload));

    try {
      final response = await completer.future.timeout(
        WebSocketConfig.responseTimeout,
        onTimeout: () {
          _pendingRequests.remove(requestId);
          throw TimeoutException('Ovozli javob vaqti tugadi');
        },
      );

      final responseText = response['data']?['response'] ?? 'Javob olinmadi';
      return responseText.length > 200 ? '${responseText.substring(0, 200)}...' : responseText;
    } catch (e) {
      _pendingRequests.remove(requestId);
      throw Exception('Ovozli javob xatoligi: $e');
    }
  }

  /// Server holati haqida ma'lumot so'rash
  Future<Map<String, dynamic>> getServerStatus() async {
    if (!isConnected) {
      throw Exception(_connectionState == WebSocketConnectionState.hostNotFound 
          ? 'AI server topilmadi. URL manzilini tekshiring.'
          : 'AI server bilan aloqa yo\'q');
    }

    final requestId = 'status_${++_requestCounter}';
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestId] = completer;

    final payload = {
      'type': 'status',
      'request_id': requestId,
    };

    _channel?.sink.add(jsonEncode(payload));

    try {
      final response = await completer.future.timeout(
        const Duration(seconds: 10),
      );

      return response['data'] ?? {};
    } catch (e) {
      _pendingRequests.remove(requestId);
      return {'error': e.toString()};
    }
  }

  /// AI javobini TalentAnalysis ga aylantirish
  TalentAnalysis _parseAnalysisResponse(Map<String, dynamic> data) {
    try {
      final levelStr = data['level'] as String? ?? 'developing';
      final level = _parseLevel(levelStr);
      
      return TalentAnalysis(
        level: level,
        summary: data['summary'] as String? ?? 'AI tahlil bajarildi',
        strengths: List<String>.from(data['strengths'] ?? []),
        improvements: List<String>.from(data['improvements'] ?? []),
        recommendations: List<String>.from(data['recommendations'] ?? []),
        skillScores: Map<String, double>.from(data['skill_scores'] ?? {
          'Tushunish': 0.7,
          'Tezlik': 0.6,
          'Izchillik': 0.8,
          'Umumiy': 0.7,
        }),
        aptitudeType: data['aptitude_type'] as String? ?? 'Umumiy',
      );
    } catch (e) {
      // Fallback tahlil
      return const TalentAnalysis(
        level: TalentLevel.developing,
        summary: 'AI tahlil formatida xatolik',
        strengths: ['Faol ishtirok'],
        improvements: ['Ko\'proq mashq qilish'],
        recommendations: ['Har kuni mashq qiling'],
        skillScores: {'Umumiy': 0.6},
        aptitudeType: 'Umumiy',
      );
    }
  }

  /// Level string ni enum ga o'girish
  TalentLevel _parseLevel(String levelStr) {
    switch (levelStr.toLowerCase()) {
      case 'beginner':
        return TalentLevel.beginner;
      case 'developing':
        return TalentLevel.developing;
      case 'proficient':
        return TalentLevel.proficient;
      case 'advanced':
        return TalentLevel.advanced;
      case 'gifted':
        return TalentLevel.gifted;
      default:
        return TalentLevel.developing;
    }
  }

  /// Xizmatni to'xtatish
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller.close();
    
    // Barcha kutilayotgan javoblarni bekor qilish
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError('Service disposed');
      }
    }
    _pendingRequests.clear();
  }

  /// Xabar yuborish (umumiy)
  void send(Map<String, dynamic> message) {
    if (isConnected) {
      _channel?.sink.add(jsonEncode(message));
    }
  }

  /// Connection status widget uchun ma'lumot
  String getStatusMessage() {
    switch (_connectionState) {
      case WebSocketConnectionState.disconnected:
        return 'Ulanmagan';
      case WebSocketConnectionState.connecting:
        return 'Ulanmoqda...';
      case WebSocketConnectionState.connected:
        return 'Ulangan';
      case WebSocketConnectionState.failed:
        return 'Ulanish xatoligi: ${_lastError ?? "Noma'lum"}';
      case WebSocketConnectionState.hostNotFound:
        final remaining = _lastHostNotFoundTime != null 
            ? WebSocketConfig.hostNotFoundCooldown - DateTime.now().difference(_lastHostNotFoundTime!)
            : Duration.zero;
        return 'Server topilmadi (${remaining.inMinutes}m qoldi)';
    }
  }

  /// Manual test uchun - server ulanishini tekshirish
  Future<void> manualConnectionTest() async {
    debugPrint('🔍 Manual WebSocket test boshlandi');
    final info = getConnectionInfo();
    debugPrint('📊 Connection info: $info');
    
    if (_connectionState == WebSocketConnectionState.hostNotFound) {
      debugPrint('❄️ Host not found cooldown aktiv');
      return;
    }
    
    if (!isConnected) {
      debugPrint('🔄 Ulanish urinishi...');
      await connect();
    } else {
      debugPrint('✅ Allaqachon ulangan');
      final testResult = await testConnection();
      debugPrint('🔍 Test natijasi: $testResult');
    }
  }
}