// ============================================================
// TalimZ — Data Models
// ============================================================

class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int xp;
  final int level;
  final int streak;
  final String grade;
  final String title;
  final List<BadgeModel> badges;
  final int completedTests;
  final double averageScore;
  final int studyDays;
  final String role; // 'student' | 'teacher'

  const UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.xp,
    required this.level,
    required this.streak,
    required this.grade,
    required this.title,
    required this.badges,
    required this.completedTests,
    required this.averageScore,
    required this.studyDays,
    this.role = 'student',
  });

  UserModel copyWith({
    int? xp,
    int? streak,
    int? completedTests,
    double? averageScore,
    List<BadgeModel>? badges,
  }) {
    return UserModel(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      xp: xp ?? this.xp,
      level: level,
      streak: streak ?? this.streak,
      grade: grade,
      title: title,
      badges: badges ?? this.badges,
      completedTests: completedTests ?? this.completedTests,
      averageScore: averageScore ?? this.averageScore,
      studyDays: studyDays,
      role: role,
    );
  }
}

class BadgeModel {
  final String id;
  final String name;
  final String icon;
  final bool isUnlocked;
  final String description;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.isUnlocked,
    this.description = '',
  });
}

class SubjectModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final double progress;
  final int totalLessons;
  final int completedLessons;
  final SubjectColor color;
  final List<String> topics;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    required this.color,
    this.topics = const [],
  });
}

enum SubjectColor { blue, orange, green, purple, teal, yellow }

class LessonModel {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration;
  final bool isCompleted;
  final bool isCurrent;
  final int xpReward;
  final String difficulty;
  final int order;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.isCompleted,
    required this.isCurrent,
    required this.xpReward,
    required this.difficulty,
    this.order = 0,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? illustration;
  final String subject;
  final String topic;
  final int xpReward;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.illustration,
    required this.subject,
    this.topic = '',
    required this.xpReward,
    this.explanation = '',
  });
}

// ─── Quiz Result — AI tahlil uchun ─────────────────────────────────────────
class QuizResult {
  final String id;
  final String subject;
  final String topic;
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final int timeSpentSeconds;
  final DateTime completedAt;
  final List<QuestionResult> questionResults;
  final TalentAnalysis talentAnalysis;

  const QuizResult({
    required this.id,
    required this.subject,
    required this.topic,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    required this.timeSpentSeconds,
    required this.completedAt,
    required this.questionResults,
    required this.talentAnalysis,
  });

  double get percentage => totalQuestions > 0
      ? (correctAnswers / totalQuestions) * 100
      : 0;
}

class QuestionResult {
  final String questionId;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final int timeSpentSeconds;

  const QuestionResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeSpentSeconds,
  });
}

// ─── Talent/Iqtidor tahlili ─────────────────────────────────────────────────
class TalentAnalysis {
  final TalentLevel level;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;
  final Map<String, double> skillScores; // skill → 0.0–1.0
  final String aptitudeType; // 'Matematik', 'Analitik', 'Ijodiy', etc.

  const TalentAnalysis({
    required this.level,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
    required this.skillScores,
    required this.aptitudeType,
  });
}

enum TalentLevel { beginner, developing, proficient, advanced, gifted }

extension TalentLevelExt on TalentLevel {
  String get label {
    switch (this) {
      case TalentLevel.beginner:
        return 'Boshlang\'ich';
      case TalentLevel.developing:
        return 'Rivojlanmoqda';
      case TalentLevel.proficient:
        return 'Malakali';
      case TalentLevel.advanced:
        return 'Ilg\'or';
      case TalentLevel.gifted:
        return 'Iqtidorli';
    }
  }

  String get icon {
    switch (this) {
      case TalentLevel.beginner:
        return '🌱';
      case TalentLevel.developing:
        return '🌿';
      case TalentLevel.proficient:
        return '⭐';
      case TalentLevel.advanced:
        return '🔥';
      case TalentLevel.gifted:
        return '💎';
    }
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isAi;
  final DateTime timestamp;
  final List<String>? codeBlocks;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isAi,
    required this.timestamp,
    this.codeBlocks,
    this.type = MessageType.text,
  });
}

enum MessageType { text, formula, result, suggestion }

class TaskModel {
  final String id;
  final String title;
  final String subject;
  final String subjectIcon;
  final int duration;
  final int xpReward;
  final bool isCompleted;
  final TaskType type;

  const TaskModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectIcon,
    required this.duration,
    required this.xpReward,
    required this.isCompleted,
    required this.type,
  });
}

enum TaskType { test, lesson, practice }

class LearningPathNode {
  final String id;
  final String title;
  final NodeStatus status;
  final double offsetX;
  final double offsetY;
  final String? milestoneImage;
  final int? xpMilestone;

  const LearningPathNode({
    required this.id,
    required this.title,
    required this.status,
    required this.offsetX,
    required this.offsetY,
    this.milestoneImage,
    this.xpMilestone,
  });
}

enum NodeStatus { completed, current, locked, milestone }

// ─── Subject Roadmap ─────────────────────────────────────────────────────────
class SubjectRoadmapModel {
  final String subjectId;
  final String subjectName;
  final List<RoadmapTopicModel> topics;
  final int totalXP;
  final int earnedXP;

  const SubjectRoadmapModel({
    required this.subjectId,
    required this.subjectName,
    required this.topics,
    required this.totalXP,
    required this.earnedXP,
  });

  double get progress => totalXP > 0 ? earnedXP / totalXP : 0.0;
}

class RoadmapTopicModel {
  final String id;
  final String title;
  final String icon;
  final RoadmapTopicStatus status;
  final int xpReward;
  final int lessonCount;
  final int completedLessons;
  final bool isMilestone;
  final String? specialTag; // "JORIY", "BONUS", etc.

  const RoadmapTopicModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.status,
    required this.xpReward,
    required this.lessonCount,
    required this.completedLessons,
    this.isMilestone = false,
    this.specialTag,
  });

  double get progress => lessonCount > 0 ? completedLessons / lessonCount : 0.0;
}

enum RoadmapTopicStatus { 
  completed, 
  current, 
  locked,
  bonus // bonus topiclar uchun
}

class WeeklyActivity {
  final String day;
  final int minutes;

  const WeeklyActivity({required this.day, required this.minutes});
}

// ─── Student — o'qituvchi uchun kengaytirilgan ──────────────────────────────
class StudentModel {
  final String id;
  final String name;
  final String avatarUrl;
  final double attendance;
  final double score;
  final String grade;
  final String subject;
  final TalentLevel talentLevel;
  final Map<String, double> subjectScores;
  final List<QuizResult> recentResults;
  final String aptitudeType;
  final bool needsAttention;

  const StudentModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.attendance,
    required this.score,
    required this.grade,
    required this.subject,
    this.talentLevel = TalentLevel.developing,
    this.subjectScores = const {},
    this.recentResults = const [],
    this.aptitudeType = 'Analitik',
    this.needsAttention = false,
  });
}

// ─── Subject Task (fan ichidagi topshiriqlar) ───────────────────────────────
enum SubjectTaskType { video, article, test, homework }

class SubjectTaskModel {
  final String id;
  final String lessonId;
  final String title;
  final String subtitle;
  final SubjectTaskType type;
  final double? progress;
  final String? dueDate;

  const SubjectTaskModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.type,
    this.progress,
    this.dueDate,
  });
}

// ─── Topic Group (fan ichidagi mavzular) ────────────────────────────────────
enum TopicType { video, article, practice }

class TopicGroupModel {
  final String id;
  final String lessonId;
  final String title;
  final String subtitle;
  final TopicType type;
  final double? progress;

  const TopicGroupModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.subtitle,
    required this.type,
    this.progress,
  });
}

// ─── Notification ───────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String icon;
  final DateTime time;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.time,
    this.isRead = false,
  });
}
