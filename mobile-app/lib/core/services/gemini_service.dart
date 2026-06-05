import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';
import 'websocket_ai_service.dart';

/// Gemini AI bilan aloqa qilish uchun xizmat
class GeminiService {
  static const String _defaultApiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Google AI Studio dan oling
  static GenerativeModel? _model;
  
  // Singleton pattern
  static GeminiService? _instance;
  GeminiService._();
  
  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// API kalitini sozlash
  static void initialize(String apiKey) {
    final key = apiKey.isEmpty ? _defaultApiKey : apiKey;
    if (key == 'YOUR_GEMINI_API_KEY_HERE' || key.isEmpty) {
      debugPrint('⚠️ Gemini API kaliti sozlanmagan! Gemini xizmati ishlamaydi.');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Chat suhbati uchun javob olish
  Future<String> sendMessage(String message, {
    String? subject,
    String? context,
    List<ChatMessage>? chatHistory,
  }) async {
    try {
      // Birinchi WebSocket AI server ni sinab ko'ramiz
      if (WebSocketAiService().isConnected) {
        return await WebSocketAiService().sendChatMessage(
          message,
          subject: subject,
          context: context,
          chatHistory: chatHistory,
        );
      }

      // WebSocket AI ishlamasa, Gemini API ni ishlatamiz
      if (_model == null) {
        return _getMockResponse(message, subject);
      }

      final prompt = _buildPrompt(message, subject: subject, context: context, chatHistory: chatHistory);
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'Kechirasiz, javob ololmadim. Iltimos, qaytadan urinib ko\'ring.';
    } catch (e) {
      return _getMockResponse(message, subject);
    }
  }

  /// Chat stream uchun (real-time typing effect)
  Stream<String> sendMessageStream(String message, {
    String? subject,
    String? context,
    List<ChatMessage>? chatHistory,
  }) async* {
    try {
      if (_model == null) {
        yield 'API kalit sozlanmagan!';
        return;
      }

      final prompt = _buildPrompt(message, subject: subject, context: context, chatHistory: chatHistory);
      final content = [Content.text(prompt)];
      
      final response = _model!.generateContentStream(content);
      
      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }
    } catch (e) {
      yield 'Xatolik: ${e.toString()}';
    }
  }

  /// Quiz tahlili uchun maxsus so'rov
  Future<TalentAnalysis> analyzeQuizWithAI({
    required List<QuestionResult> results,
    required String subject,
    required String topic,
    required int timeSpentSeconds,
  }) async {
    try {
      // Birinchi WebSocket AI server ni sinab ko'ramiz
      if (WebSocketAiService().isConnected) {
        return await WebSocketAiService().analyzeQuiz(
          results: results,
          subject: subject,
          topic: topic,
          timeSpentSeconds: timeSpentSeconds,
        );
      }

      // WebSocket ishlamasa, Gemini API ni ishlatamiz
      if (_model == null) {
        throw Exception('API kalit sozlanmagan');
      }

      final prompt = _buildAnalysisPrompt(results, subject, topic, timeSpentSeconds);
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return _parseAnalysisResponse(response.text ?? '', subject);
    } catch (e) {
      // Fallback - mahalliy tahlil qaytarish
      return _createFallbackAnalysis(results, subject);
    }
  }

  /// Ovozli suhbat uchun qisqa javob
  Future<String> getVoiceResponse(String message, {String? subject}) async {
    try {
      // Birinchi WebSocket AI server ni sinab ko'ramiz
      if (WebSocketAiService().isConnected) {
        return await WebSocketAiService().getVoiceResponse(message, subject: subject);
      }

      // WebSocket ishlamasa, oddiy sendMessage ishlatamiz
      final response = await sendMessage(message, subject: subject);
      return response.length > 200 ? '${response.substring(0, 200)}...' : response;
    } catch (e) {
      return 'Ovozli javob olishda xatolik yuz berdi.';
    }
  }

  /// Prompt yaratish funksiyasi
  String _buildPrompt(String message, {
    String? subject,
    String? context,
    List<ChatMessage>? chatHistory,
  }) {
    final buffer = StringBuffer();
    
    // Asosiy rol va kontekst
    buffer.writeln('''
Sen TalimZ ilovasidagi AI mentor TalimZ-san. Oʻzbekiston oʻquvchilari uchun taʻlim beruvchi virtual ustozsing.

SHAXSIYAT:
- Dostona, sabr-toqatli va motivatsion
- Oʻzbek tilida suhbatlashadi
- Pedagogik yondashuvni qo'llaydi
- Har doim qo'llab-quvvatlaydi

VAZIFA:
- Fanlarga yordam berish (Matematika, Fizika, Kimyo, Biologiya, Tarix, va boshqalar)
- Tushuntirish, misol keltirish
- Test savollari yaratish va baholash
- Motivatsiya va yo'nalish berish
''');

    // Fan konteksti
    if (subject != null && subject.isNotEmpty) {
      buffer.writeln('Joriy fan: $subject');
    }

    // Qo'shimcha kontekst
    if (context != null && context.isNotEmpty) {
      buffer.writeln('Kontekst: $context');
    }

    // Suhbat tarixi
    if (chatHistory != null && chatHistory.isNotEmpty) {
      buffer.writeln('\nSuhbat tarixi:');
      final recentMessages = chatHistory.length > 5 
          ? chatHistory.sublist(chatHistory.length - 5)
          : chatHistory;
      
      for (final msg in recentMessages) {
        buffer.writeln('${msg.isAi ? "TalimZ" : "O'quvchi"}: ${msg.content}');
      }
    }

    buffer.writeln('\nOʻquvchining yangi savoli: $message');
    buffer.writeln('\nJavob (oʻzbek tilida, aniq va tushunarli):');

    return buffer.toString();
  }

  /// Tahlil uchun prompt
  String _buildAnalysisPrompt(
    List<QuestionResult> results,
    String subject,
    String topic,
    int timeSpentSeconds,
  ) {
    final correct = results.where((r) => r.isCorrect).length;
    final total = results.length;
    final accuracy = total > 0 ? (correct / total * 100).toStringAsFixed(1) : '0';
    
    return '''
O'quvchining test natijasini tahlil qil va JSON formatda javob ber:

TEST MA'LUMOTLARI:
- Fan: $subject
- Mavzu: $topic  
- Jami savollar: $total
- To'g'ri javoblar: $correct
- Aniqlik: $accuracy%
- Sarflangan vaqt: ${timeSpentSeconds}s

JAVOB FORMATI (faqat JSON):
{
  "level": "beginner|developing|proficient|advanced|gifted",
  "summary": "Qisqacha baholash",
  "strengths": ["Kuchli tomonlar"],
  "improvements": ["Yaxshilanishi kerak joylar"],  
  "recommendations": ["Tavsiyalar"],
  "aptitudeType": "O'quvchi turi"
}

Javobni oʻzbek tilida ber.
''';
  }

  /// AI javobini parse qilish
  TalentAnalysis _parseAnalysisResponse(String response, String subject) {
    try {
      // JSON qismini ajratib olish
      final startIndex = response.indexOf('{');
      final endIndex = response.lastIndexOf('}') + 1;
      
      if (startIndex >= 0 && endIndex > startIndex) {
        final jsonStr = response.substring(startIndex, endIndex);
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        
        return TalentAnalysis(
          level: _parseLevel(json['level'] as String? ?? 'developing'),
          summary: json['summary'] as String? ?? 'Tahlil',
          strengths: List<String>.from(json['strengths'] as List? ?? []),
          improvements: List<String>.from(json['improvements'] as List? ?? []),
          recommendations: List<String>.from(json['recommendations'] as List? ?? []),
          skillScores: {
            'Tushunish': 0.7,
            'Tezlik': 0.6,  
            'Izchillik': 0.8,
            'Umumiy': 0.7,
          },
          aptitudeType: json['aptitudeType'] as String? ?? 'Umumiy',
        );
      }
    } catch (e) {
      // Debugging uchun comment qilingan
      // print('JSON parse xatolik: $e');
    }
    
    return _createFallbackAnalysis([], subject);
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

  /// Fallback tahlil (xatolik holatida)
  TalentAnalysis _createFallbackAnalysis(List<QuestionResult> results, String subject) {
    return TalentAnalysis(
      level: TalentLevel.developing,
      summary: 'AI tahlil hozirda mavjud emas. Asosiy tahlil ko\'rsatildi.',
      strengths: ['Faol ishtirok', 'O\'rganishga ishtiyoq'],
      improvements: ['Ko\'proq mashq qilish', 'Tushunchalarni mustahkamlash'],
      recommendations: ['Har kuni 30 daqiqa mashq qiling', 'Qiyinchilik tug\'ilganda yordam so\'rang'],
      skillScores: {
        'Tushunish': 0.6,
        'Tezlik': 0.5,
        'Izchillik': 0.7,
        'Umumiy': 0.6,
      },
      aptitudeType: 'Umumiy',
    );
  }

  /// Mock javob - API key noto'g'ri bo'lganda
  String _getMockResponse(String message, String? subject) {
    final responses = [
      'Assalomu alaykum! Men TalimZ AI mentoriman. Sizga qanday yordam bera olaman?',
      'Bu savolga javob berish uchun Google Gemini API kalitni to\'g\'ri sozlash kerak.',
      'Hozircha mock rejimda ishlayapman. ${subject ?? "Fan"} bo\'yicha savolingizni tushundim.',
      'API kalit sozlangandan keyin to\'liq AI javoblarni berishni boshlayman.',
      'Matematika, fizika, kimyo va boshqa fanlar bo\'yicha yordam berishga tayyorman.',
    ];
    return responses[message.length % responses.length];
  }
}