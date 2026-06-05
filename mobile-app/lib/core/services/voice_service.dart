import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

/// Ovozli suhbat xizmati - Speech-to-Text va Text-to-Speech
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _textToSpeech = FlutterTts();
  
  final StreamController<VoiceState> _stateController = StreamController<VoiceState>.broadcast();
  final StreamController<String> _transcriptionController = StreamController<String>.broadcast();
  final StreamController<double> _volumeController = StreamController<double>.broadcast();
  
  VoiceState _currentState = VoiceState.idle;
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastTranscription = '';
  Timer? _silenceTimer;
  
  // Getter'lar
  Stream<VoiceState> get stateStream => _stateController.stream;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  VoiceState get currentState => _currentState;
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastTranscription => _lastTranscription;

  /// Xizmatni ishga tushirish
  Future<bool> initialize() async {
    try {
      // Mikrofon ruxsatini tekshirish
      final micPermission = await Permission.microphone.request();
      if (micPermission != PermissionStatus.granted) {
        _setState(VoiceState.error);
        return false;
      }

      // Speech-to-Text ni ishga tushirish
      final sttAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );

      if (!sttAvailable) {
        _setState(VoiceState.error);
        return false;
      }

      // Text-to-Speech ni sozlash
      await _textToSpeech.setLanguage('uz-UZ'); // O'zbek tili
      await _textToSpeech.setSpeechRate(0.7); // Tezlik
      await _textToSpeech.setVolume(0.8); // Ovoz balandligi
      await _textToSpeech.setPitch(1.0); // Ohang

      // Completion callback
      _textToSpeech.setCompletionHandler(() {
        if (_currentState == VoiceState.speaking) {
          _setState(VoiceState.idle);
        }
      });

      _isInitialized = true;
      _setState(VoiceState.idle);
      return true;
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('Voice Service init xatolik: $e');
      _setState(VoiceState.error);
      return false;
    }
  }

  /// Tinglashni boshlash
  Future<bool> startListening() async {
    if (!_isInitialized || _isListening) return false;

    try {
      // TTS to'xtatish (agar gapirsa)
      await stopSpeaking();
      
      _setState(VoiceState.listening);
      _lastTranscription = '';
      
      final success = await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
      
      if (success) {
        _isListening = true;
        _startSilenceTimer();
        return true;
      } else {
        _setState(VoiceState.error);
        return false;
      }
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('Start listening xatolik: $e');
      _setState(VoiceState.error);
      return false;
    }
  }

  /// Tinglashni to'xtatish
  Future<void> stopListening() async {
    if (!_isListening) return;
    
    try {
      await _speechToText.stop();
      _isListening = false;
      _silenceTimer?.cancel();
      
      if (_lastTranscription.isNotEmpty) {
        _setState(VoiceState.processing);
      } else {
        _setState(VoiceState.idle);
      }
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('Stop listening xatolik: $e');
      _setState(VoiceState.error);
    }
  }

  /// Matnni ovozga aylantirish
  Future<void> speak(String text) async {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // Avval to'xtatamiz
      await stopSpeaking();
      
      _setState(VoiceState.speaking);
      
      // O'zbek tiliga moslashtirish
      final cleanText = _cleanTextForSpeech(text);
      await _textToSpeech.speak(cleanText);
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('Speak xatolik: $e');
      _setState(VoiceState.error);
    }
  }

  /// Gapirashni to'xtatish
  Future<void> stopSpeaking() async {
    try {
      await _textToSpeech.stop();
      if (_currentState == VoiceState.speaking) {
        _setState(VoiceState.idle);
      }
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('Stop speaking xatolik: $e');
    }
  }

  /// Ovoz balandligini sozlash (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    await _textToSpeech.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Gapirish tezligini sozlash (0.1 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    await _textToSpeech.setSpeechRate(rate.clamp(0.1, 1.0));
  }

  /// Xizmatni tozalash
  Future<void> dispose() async {
    _silenceTimer?.cancel();
    await stopListening();
    await stopSpeaking();
    
    await _stateController.close();
    await _transcriptionController.close();
    await _volumeController.close();
  }

  // === Private Methods ===

  void _setState(VoiceState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }

  void _onSpeechResult(dynamic result) {
    // The result parameter is from speech_to_text package
    final recognizedWords = result.recognizedWords as String? ?? '';
    final finalResult = result.finalResult as bool? ?? false;
    
    _lastTranscription = recognizedWords;
    _transcriptionController.add(_lastTranscription);
    
    // Agar final natija bo'lsa, qayta timer boshlash
    if (finalResult) {
      _silenceTimer?.cancel();
      _startSilenceTimer();
    }
  }

  void _onSpeechStatus(String status) {
    // Debugging uchun comment qilingan
    // print('Speech status: $status');
    
    switch (status) {
      case 'listening':
        if (!_isListening) {
          _isListening = true;
        }
        break;
      case 'notListening':
        _isListening = false;
        if (_lastTranscription.isNotEmpty) {
          _setState(VoiceState.processing);
        } else {
          _setState(VoiceState.idle);
        }
        break;
      case 'done':
        _isListening = false;
        _setState(VoiceState.idle);
        break;
    }
  }

  void _onSpeechError(dynamic error) {
    // Debugging uchun comment qilingan  
    // print('Speech xatolik: $error');
    _isListening = false;
    _setState(VoiceState.error);
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 3), () {
      if (_isListening && _lastTranscription.isNotEmpty) {
        stopListening();
      }
    });
  }

  /// Ovoz uchun matnni tozalash
  String _cleanTextForSpeech(String text) {
    // Emoji va maxsus belgilarni olib tashlash
    String clean = text.replaceAll(RegExp(r'[^\w\s\u0400-\u04FF.,!?-]'), '');
    
    // Ko'p probel va qatorlarni tozalash  
    clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Matematik formulalarni o'qiladigan qilib o'zgartirish
    clean = clean.replaceAll('²', ' kvadrat');
    clean = clean.replaceAll('³', ' kub');
    clean = clean.replaceAll('π', 'pi');
    clean = clean.replaceAll('√', 'ildiz');
    
    return clean;
  }
}

/// Voice Service uchun Singleton provider
class VoiceServiceProvider {
  static final VoiceService _instance = VoiceService();
  
  static VoiceService get instance => _instance;
}