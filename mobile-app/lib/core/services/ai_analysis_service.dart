import '../models/models.dart';
import 'gemini_service.dart';

/// AI tahlil xizmati — test natijalari asosida iqtidor tahlili
/// Backend ulanganda bu yerga API call qo'shiladi
class AiAnalysisService {
  /// Test natijasidan TalentAnalysis yaratadi (Gemini AI bilan)
  static Future<TalentAnalysis> analyzeQuizResult({
    required List<QuestionResult> results,
    required String subject,
    required String topic,
    required int timeSpentSeconds,
  }) async {
    try {
      // Avval Gemini AI bilan tahlil qilishga harakat qilamiz
      final aiAnalysis = await GeminiService.instance.analyzeQuizWithAI(
        results: results,
        subject: subject,
        topic: topic,
        timeSpentSeconds: timeSpentSeconds,
      );
      return aiAnalysis;
    } catch (e) {
      // AI tahlil xatoligi qayd etildi
      // Debug: print('AI tahlil xatoligi: $e');
      // Fallback - oddiy tahlil
      return analyzeLocally(results, subject, topic, timeSpentSeconds);
    }
  }

  /// Mahalliy tahlil (AI ishlamasa)
  static TalentAnalysis analyzeLocally(
    List<QuestionResult> results,
    String subject,
    String topic,
    int timeSpentSeconds,
  ) {
    final total = results.length;
    if (total == 0) {
      return _defaultAnalysis();
    }

    final correct = results.where((r) => r.isCorrect).length;
    final accuracy = correct / total;
    final avgTime = timeSpentSeconds / total;

    // Tezlik tahlili (sekundda har bir savol)
    final speedScore = _calcSpeedScore(avgTime);
    // To'g'rilik
    final accuracyScore = accuracy;
    // Izchillik — ketma-ket to'g'ri javoblar
    final consistencyScore = _calcConsistencyScore(results);
    // Umumiy iqtidor
    final overallScore = (accuracyScore * 0.5 + speedScore * 0.25 + consistencyScore * 0.25);

    final level = _scoreToLevel(overallScore);
    final aptitude = _detectAptitude(subject, accuracy, speedScore);

    return TalentAnalysis(
      level: level,
      summary: _buildSummary(level, subject, accuracy, aptitude),
      strengths: _buildStrengths(accuracy, speedScore, consistencyScore, subject),
      improvements: _buildImprovements(results, accuracy, speedScore),
      recommendations: _buildRecommendations(level, subject, accuracy),
      skillScores: {
        'Tushunish': accuracyScore,
        'Tezlik': speedScore,
        'Izchillik': consistencyScore,
        'Umumiy': overallScore,
      },
      aptitudeType: aptitude,
    );
  }

  /// Bir nechta quiz natijalarini tahlil qilib, o'quvchi profili
  static TalentAnalysis analyzeStudentProfile({
    required List<QuizResult> results,
    required String studentName,
  }) {
    if (results.isEmpty) return _defaultAnalysis();

    // Fan bo'yicha o'rtacha
    final subjectMap = <String, List<double>>{};
    for (final r in results) {
      subjectMap.putIfAbsent(r.subject, () => []);
      subjectMap[r.subject]!.add(r.percentage / 100);
    }

    final subjectAvg = subjectMap.map(
      (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
    );

    final overall = subjectAvg.values.isEmpty
        ? 0.0
        : subjectAvg.values.reduce((a, b) => a + b) / subjectAvg.length;

    final level = _scoreToLevel(overall);
    final topSubject = subjectAvg.entries.isEmpty
        ? 'Matematika'
        : subjectAvg.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
    final aptitude = _detectAptitude(topSubject, overall, 0.6);

    return TalentAnalysis(
      level: level,
      summary: '$studentName ${level.label} darajasida. '
          'Eng kuchli fani: $topSubject. '
          '$aptitude yo\'nalishida iqtidor sezilmoqda.',
      strengths: [
        if (overall > 0.7) '$topSubject fanida yuqori natija',
        if (results.length > 5) 'Muntazam test yechadi',
        if (_hasImprovingTrend(results)) 'Natijalar oshib bormoqda',
      ],
      improvements: [
        if (overall < 0.6) 'Asosiy tushunchalarni mustahkamlash kerak',
        ...subjectAvg.entries
            .where((e) => e.value < 0.5)
            .map((e) => '${e.key} fanini ko\'proq mashq qilish kerak'),
      ],
      recommendations: _buildRecommendations(level, topSubject, overall),
      skillScores: {
        ...subjectAvg,
        'Umumiy': overall,
      },
      aptitudeType: aptitude,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────

  static double _calcSpeedScore(double avgTimeSeconds) {
    if (avgTimeSeconds < 10) return 1.0;
    if (avgTimeSeconds < 20) return 0.85;
    if (avgTimeSeconds < 30) return 0.65;
    if (avgTimeSeconds < 45) return 0.45;
    return 0.25;
  }

  static double _calcConsistencyScore(List<QuestionResult> results) {
    if (results.length < 2) return results.isNotEmpty && results[0].isCorrect ? 1.0 : 0.0;
    int maxStreak = 0, currentStreak = 0;
    for (final r in results) {
      if (r.isCorrect) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
    }
    return maxStreak / results.length;
  }

  static TalentLevel _scoreToLevel(double score) {
    if (score >= 0.90) return TalentLevel.gifted;
    if (score >= 0.75) return TalentLevel.advanced;
    if (score >= 0.60) return TalentLevel.proficient;
    if (score >= 0.40) return TalentLevel.developing;
    return TalentLevel.beginner;
  }

  static String _detectAptitude(
      String subject, double accuracy, double speed) {
    final isQuantitative = ['Matematika', 'Fizika', 'Kimyo'].contains(subject);
    if (isQuantitative && accuracy > 0.75) return 'Matematik';
    if (isQuantitative && speed > 0.75) return 'Analitik';
    if (!isQuantitative && accuracy > 0.75) return 'Gumanitar';
    if (speed > 0.8) return 'Tezkor o\'ylovchi';
    return 'Izchil o\'rganuvchi';
  }

  static String _buildSummary(
      TalentLevel level, String subject, double accuracy, String aptitude) {
    final pct = (accuracy * 100).toInt();
    return '$subject bo\'yicha $pct% to\'g\'rilik bilan ${level.label} darajasini ko\'rsatdi. '
        '$aptitude yo\'nalishida kuchli potensial mavjud.';
  }

  static List<String> _buildStrengths(
      double acc, double speed, double cons, String subject) {
    final s = <String>[];
    if (acc > 0.75) s.add('$subject bo\'yicha mustahkam bilim');
    if (speed > 0.70) s.add('Savollarni tez tahlil qiladi');
    if (cons > 0.60) s.add('Javoblarda izchillik yuqori');
    if (s.isEmpty) s.add('Asosiy tushunchalarni o\'zlashtirgan');
    return s;
  }

  static List<String> _buildImprovements(
      List<QuestionResult> results, double acc, double speed) {
    final s = <String>[];
    if (acc < 0.60) s.add('Mavzu bo\'yicha qo\'shimcha mashqlar tavsiya etiladi');
    if (speed < 0.50) s.add('Savol yechish tezligini oshirish kerak');
    final wrongCount = results.where((r) => !r.isCorrect).length;
    if (wrongCount > 0) s.add('$wrongCount ta xato savolni qayta ko\'rib chiqish');
    return s;
  }

  static List<String> _buildRecommendations(
      TalentLevel level, String subject, double accuracy) {
    switch (level) {
      case TalentLevel.gifted:
        return [
          'Olimpiada masalalarini yechishni boshlash',
          '$subject bo\'yicha chuqur kurs',
          'Tengdoshlarga yordam berish orqali bilimni mustahkamlash',
        ];
      case TalentLevel.advanced:
        return [
          'Murakkab masalalar to\'plamidan foydalanish',
          'Vaqt chegarali mashqlar',
          '$subject bo\'yicha test seriyasini davom ettirish',
        ];
      case TalentLevel.proficient:
        return [
          'Kuniga 20 daqiqa $subject bo\'yicha mashq',
          'AI mentor bilan formula takrorlash',
          'Qiyin savollar ustida ko\'proq vaqt sarflash',
        ];
      case TalentLevel.developing:
        return [
          'Asosiy tushunchalarni video darslar orqali qayta o\'rganish',
          'Oson savollardan boshlash',
          'TalimZ Mentordan tushuntirish so\'rash',
        ];
      case TalentLevel.beginner:
        return [
          'Asosiy darslarni qaytadan ko\'rish',
          'Kuniga 10 daqiqa o\'qish',
          'O\'qituvchidan qo\'shimcha yordam so\'rash',
        ];
    }
  }

  static bool _hasImprovingTrend(List<QuizResult> results) {
    if (results.length < 3) return false;
    final sorted = [...results]..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    final recent = sorted.takeLast(3).map((r) => r.percentage).toList();
    return recent[2] > recent[0];
  }

  static TalentAnalysis _defaultAnalysis() => const TalentAnalysis(
        level: TalentLevel.developing,
        summary: 'Hali yetarli ma\'lumot yo\'q. Testlarni yeching!',
        strengths: ['O\'rganishga tayyor'],
        improvements: ['Ko\'proq test yechish kerak'],
        recommendations: ['Bugun birinchi testni boshlang'],
        skillScores: {'Umumiy': 0.5},
        aptitudeType: 'Rivojlanmoqda',
      );
}

extension<T> on Iterable<T> {
  Iterable<T> takeLast(int n) {
    final list = toList();
    if (list.length <= n) return list;
    return list.sublist(list.length - n);
  }
}
