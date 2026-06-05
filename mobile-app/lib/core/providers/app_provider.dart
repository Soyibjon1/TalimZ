import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../services/ai_analysis_service.dart';

/// Asosiy state — butun app uchun
class AppProvider extends ChangeNotifier {
  UserModel _user = MockData.currentUser;
  final List<QuizResult> _quizHistory = [];
  TalentAnalysis? _latestAnalysis;
  int _totalXpSession = 0;

  UserModel get user => _user;
  UserModel get currentUser => _user; // Alias for currentUser
  List<QuizResult> get quizHistory => List.unmodifiable(_quizHistory);
  TalentAnalysis? get latestAnalysis => _latestAnalysis;
  int get totalXpSession => _totalXpSession;

  /// Test yakunlanganda chaqiriladi
  void recordQuizResult(QuizResult result) {
    _quizHistory.add(result);
    _totalXpSession += result.xpEarned;

    // XP qo'shish
    _user = _user.copyWith(
      xp: _user.xp + result.xpEarned,
      completedTests: _user.completedTests + 1,
      averageScore: _calcNewAverage(result.percentage),
    );

    // AI tahlilni yangilash (Async)
    _updateAnalysisAsync(result);

    // Badge tekshiruvi
    _checkAndUnlockBadges();

    notifyListeners();
  }

  // AI tahlilni asinxron yangilash
  void _updateAnalysisAsync(QuizResult result) async {
    try {
      final analysis = await AiAnalysisService.analyzeQuizResult(
        results: result.questionResults,
        subject: result.subject,
        topic: result.topic,
        timeSpentSeconds: result.timeSpentSeconds,
      );
      
      _latestAnalysis = analysis;
      notifyListeners();
    } catch (e) {
      // Fallback - eski usul bilan sinxron tahlil
      _latestAnalysis = AiAnalysisService.analyzeStudentProfile(
        results: _quizHistory,
        studentName: _user.name,
      );
      notifyListeners();
    }
  }

  double _calcNewAverage(double newScore) {
    if (_quizHistory.isEmpty) return newScore;
    final total = _quizHistory.fold(0.0, (s, r) => s + r.percentage);
    return total / _quizHistory.length;
  }

  void _checkAndUnlockBadges() {
    final badges = List<BadgeModel>.from(_user.badges);
    bool changed = false;

    for (int i = 0; i < badges.length; i++) {
      if (!badges[i].isUnlocked) {
        bool unlock = false;
        switch (badges[i].id) {
          case '1': // Boshlovchi
            unlock = _user.completedTests >= 1;
            break;
          case '2': // Bilimdon
            unlock = _user.completedTests >= 10;
            break;
          case '3': // Tezkor
            unlock = _quizHistory.any((r) => r.timeSpentSeconds < 60);
            break;
          case '4': // Olim
            unlock = _quizHistory.any((r) => r.percentage >= 90);
            break;
          case '5': // Champion
            unlock = _user.xp >= 5000;
            break;
        }
        if (unlock) {
          badges[i] = BadgeModel(
            id: badges[i].id,
            name: badges[i].name,
            icon: badges[i].icon,
            isUnlocked: true,
            description: badges[i].description,
          );
          changed = true;
        }
      }
    }

    if (changed) {
      _user = _user.copyWith(badges: badges);
    }
  }

  void addXp(int amount) {
    _user = _user.copyWith(xp: _user.xp + amount);
    _totalXpSession += amount;
    notifyListeners();
  }

  TalentAnalysis getStudentTalentAnalysis(StudentModel student) {
    return AiAnalysisService.analyzeStudentProfile(
      results: student.recentResults,
      studentName: student.name,
    );
  }
}

/// Quiz state — bir test sessiyasi uchun
class QuizProvider extends ChangeNotifier {
  final List<QuizQuestion> questions;
  final String subject;
  final String topic;

  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  int _totalXp = 0;
  int _timeLeft = 30;
  final List<QuestionResult> _results = [];
  final DateTime _startTime = DateTime.now();
  int _questionStartTime = 0; // milliseconds

  QuizProvider({required this.questions, required this.subject, required this.topic}) {
    _questionStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  int get currentIndex => _currentIndex;
  QuizQuestion get currentQuestion => questions[_currentIndex];
  int? get selectedAnswer => _selectedAnswer;
  bool get answered => _answered;
  int get correctCount => _correctCount;
  int get totalXp => _totalXp;
  int get timeLeft => _timeLeft;
  List<QuestionResult> get results => List.unmodifiable(_results);
  bool get isLast => _currentIndex == questions.length - 1;
  double get progress => (_currentIndex + 1) / questions.length;

  void tick() {
    if (_timeLeft > 0 && !_answered) {
      _timeLeft--;
      notifyListeners();
      if (_timeLeft == 0) _autoAnswer();
    }
  }

  void _autoAnswer() {
    _answered = true;
    final timeSpent = (DateTime.now().millisecondsSinceEpoch - _questionStartTime) ~/ 1000;
    _results.add(QuestionResult(
      questionId: currentQuestion.id,
      selectedAnswer: -1,
      correctAnswer: currentQuestion.correctIndex,
      isCorrect: false,
      timeSpentSeconds: timeSpent,
    ));
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_answered) return;
    final timeSpent = (DateTime.now().millisecondsSinceEpoch - _questionStartTime) ~/ 1000;
    _selectedAnswer = index;
    _answered = true;
    final isCorrect = index == currentQuestion.correctIndex;
    if (isCorrect) {
      _correctCount++;
      _totalXp += currentQuestion.xpReward;
    }
    _results.add(QuestionResult(
      questionId: currentQuestion.id,
      selectedAnswer: index,
      correctAnswer: currentQuestion.correctIndex,
      isCorrect: isCorrect,
      timeSpentSeconds: timeSpent,
    ));
    notifyListeners();
  }

  bool nextQuestion() {
    if (_currentIndex < questions.length - 1) {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
      _timeLeft = 30;
      _questionStartTime = DateTime.now().millisecondsSinceEpoch;
      notifyListeners();
      return true;
    }
    return false;
  }

  QuizResult buildResult() {
    final totalSeconds = DateTime.now().difference(_startTime).inSeconds;
    // Sync analysis (the full async analysis is done in AppProvider)
    final analysis = AiAnalysisService.analyzeLocally(
      _results,
      subject,
      topic,
      totalSeconds,
    );
    return QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      topic: topic,
      totalQuestions: questions.length,
      correctAnswers: _correctCount,
      xpEarned: _totalXp,
      timeSpentSeconds: totalSeconds,
      completedAt: DateTime.now(),
      questionResults: _results,
      talentAnalysis: analysis,
    );
  }
}
