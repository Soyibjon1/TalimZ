import '../models/models.dart';

class MockData {
  // ─── Current User ────────────────────────────────────────────────────────
  static const UserModel currentUser = UserModel(
    id: '1',
    name: 'Azizbek',
    avatarUrl: '',
    xp: 8420,
    level: 12,
    streak: 12,
    grade: '10-Sinf',
    title: 'Kelajak muhandisi',
    completedTests: 124,
    averageScore: 92,
    studyDays: 14,
    role: 'student',
    badges: [
      BadgeModel(id: '1', name: 'Boshlovchi', icon: '🎯', isUnlocked: true, description: 'Birinchi testni yakunladi'),
      BadgeModel(id: '2', name: 'Bilimdon', icon: '🏆', isUnlocked: true, description: '10 ta test yechdi'),
      BadgeModel(id: '3', name: 'Tezkor', icon: '🚀', isUnlocked: true, description: '1 daqiqada test yakunladi'),
      BadgeModel(id: '4', name: 'Olim', icon: '🎓', isUnlocked: true, description: '90%+ natija ko\'rsatdi'),
      BadgeModel(id: '5', name: 'Champion', icon: '👑', isUnlocked: false, description: '5000 XP to\'plash'),
    ],
  );

  // ─── Subjects ────────────────────────────────────────────────────────────
  static final List<SubjectModel> subjects = [
    const SubjectModel(
      id: '1',
      name: 'Matematika',
      description: 'Geometriya, algebra va mantiqiy masalalar yordamida dunyoni kashf qiling.',
      icon: '📐',
      progress: 0.60,
      totalLessons: 20,
      completedLessons: 12,
      color: SubjectColor.blue,
      topics: ['Algebra', 'Geometriya', 'Trigonometriya', 'Analiz', 'Statistika'],
    ),
    const SubjectModel(
      id: '2',
      name: 'Fizika',
      description: 'Koinot qonunlari va energiya sir-asrorlari.',
      icon: '⚡',
      progress: 0.35,
      totalLessons: 18,
      completedLessons: 6,
      color: SubjectColor.orange,
      topics: ['Mexanika', 'Termodinamika', 'Elektr', 'Optika', 'Kvant fizika'],
    ),
    const SubjectModel(
      id: '3',
      name: 'Kimyo',
      description: 'Elementlar va reaksiyalar olamiga sho\'ng\'ing.',
      icon: '🧪',
      progress: 0.80,
      totalLessons: 15,
      completedLessons: 12,
      color: SubjectColor.green,
      topics: ['Atom tuzilishi', 'Reaksiyalar', 'Organik kimyo', 'Eritmalar'],
    ),
    const SubjectModel(
      id: '4',
      name: 'Ingliz tili',
      description: 'Global muloqot tili va Grammatika asoslari.',
      icon: '🇬🇧',
      progress: 0.15,
      totalLessons: 22,
      completedLessons: 3,
      color: SubjectColor.purple,
      topics: ['Grammar', 'Vocabulary', 'Reading', 'Writing', 'Speaking'],
    ),
    const SubjectModel(
      id: '5',
      name: 'Tarix',
      description: 'O\'tmishdan bugungi kungacha bo\'lgan yo\'l.',
      icon: '📜',
      progress: 0.50,
      totalLessons: 16,
      completedLessons: 8,
      color: SubjectColor.teal,
      topics: ['Qadimgi tarix', 'O\'rta asrlar', 'Yangi davr', 'Zamonaviy tarix'],
    ),
  ];

  // ─── Lessons ─────────────────────────────────────────────────────────────
  static final List<LessonModel> lessons = [
    const LessonModel(id: '1', title: 'Trigonometriya asoslari', subject: 'Matematika',
        topic: 'Sinus va Kosinus funksiyalari', videoUrl: '', thumbnailUrl: '',
        duration: 24, isCompleted: false, isCurrent: true, xpReward: 15, difficulty: 'O\'rta', order: 1),
    const LessonModel(id: '2', title: 'Sinuslar teoremasi', subject: 'Matematika',
        topic: 'Sinuslar teoremasi', videoUrl: '', thumbnailUrl: '',
        duration: 20, isCompleted: false, isCurrent: false, xpReward: 20, difficulty: 'O\'rta', order: 2),
    const LessonModel(id: '3', title: 'Kosinuslar teoremasi', subject: 'Matematika',
        topic: 'Kosinuslar teoremasi', videoUrl: '', thumbnailUrl: '',
        duration: 18, isCompleted: false, isCurrent: false, xpReward: 20, difficulty: 'Qiyin', order: 3),
  ];

  // ─── Learning Path ────────────────────────────────────────────────────────
  static final List<LearningPathNode> learningPath = [
    const LearningPathNode(id: '1', title: 'Algebra asoslari', status: NodeStatus.completed, offsetX: 0.40, offsetY: 0.06),
    const LearningPathNode(id: '2', title: 'Geometriya', status: NodeStatus.completed, offsetX: 0.65, offsetY: 0.20),
    const LearningPathNode(id: '3', title: 'Trigonometriya', status: NodeStatus.current, offsetX: 0.22, offsetY: 0.36),
    const LearningPathNode(id: '4', title: 'Calculus', status: NodeStatus.milestone,
        offsetX: 0.68, offsetY: 0.54, xpMilestone: 1500),
    const LearningPathNode(id: '5', title: 'Matrisalar', status: NodeStatus.locked, offsetX: 0.35, offsetY: 0.73),
  ];

  // ─── Quiz questions — Math ────────────────────────────────────────────────
  static final List<QuizQuestion> mathQuiz = [
    const QuizQuestion(
      id: 'q1', question: 'Sinus(90°) qiymati nechaga teng?',
      options: ['1', '0', '0.5', '-1'], correctIndex: 0,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'sin(90°) = 1, chunki birlik aylana bo\'yicha 90° da ordinata 1 ga teng.',
    ),
    const QuizQuestion(
      id: 'q2', question: 'cos(0°) qiymati nechaga teng?',
      options: ['0', '1', '-1', '0.5'], correctIndex: 1,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'cos(0°) = 1, chunki 0° da abssissa 1 ga teng.',
    ),
    const QuizQuestion(
      id: 'q3', question: 'sin²(α) + cos²(α) = ?',
      options: ['0', '2', '1', 'α'], correctIndex: 2,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'Bu Pifagor ayniyati — birlik aylana radiusi 1 bo\'lgani uchun.',
    ),
    const QuizQuestion(
      id: 'q4', question: 'tan(45°) nechaga teng?',
      options: ['0', '√2', '1', '∞'], correctIndex: 2,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'tan(45°) = sin(45°)/cos(45°) = (√2/2)/(√2/2) = 1',
    ),
    const QuizQuestion(
      id: 'q5', question: 'sin(30°) nechaga teng?',
      options: ['√3/2', '1/2', '√2/2', '1'], correctIndex: 1,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'sin(30°) = 1/2. Bu standart trigonometrik qiymat.',
    ),
    const QuizQuestion(
      id: 'q6', question: 'cos(60°) nechaga teng?',
      options: ['√3/2', '√2/2', '1/2', '0'], correctIndex: 2,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'cos(60°) = 1/2. cos va sin 30° va 60° da almashadi.',
    ),
    const QuizQuestion(
      id: 'q7', question: 'sin(180°) nechaga teng?',
      options: ['1', '-1', '0', '∞'], correctIndex: 2,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'sin(180°) = 0, chunki 180° da ordinata 0 ga teng.',
    ),
    const QuizQuestion(
      id: 'q8', question: 'Qaysi formula to\'g\'ri?',
      options: ['sin(2α) = 2cos²α', 'sin(2α) = 2sinα·cosα', 'sin(2α) = sin²α - cos²α', 'sin(2α) = sinα + cosα'],
      correctIndex: 1,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'Ikki burchak sinusi formulasi: sin(2α) = 2·sin(α)·cos(α)',
    ),
    const QuizQuestion(
      id: 'q9', question: 'cos(90°) nechaga teng?',
      options: ['1', '-1', '0.5', '0'], correctIndex: 3,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'cos(90°) = 0, chunki 90° da abssissa 0 ga teng.',
    ),
    const QuizQuestion(
      id: 'q10', question: '1 + tan²(α) = ?',
      options: ['sec²(α)', 'cos²(α)', 'sin²(α)', '2'], correctIndex: 0,
      subject: 'Matematika', topic: 'TRIGONOMETRIYA ASOSLARI', xpReward: 50,
      explanation: 'Pifagor ayniyatidan: 1 + tan²(α) = sec²(α) = 1/cos²(α)',
    ),
  ];

  // ─── Chat messages ────────────────────────────────────────────────────────
  static List<ChatMessage> get initialMessages => [
        ChatMessage(
          id: '1', content: 'Salom! Qaysi fandan yordam bera olaman?',
          isAi: true, timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        ChatMessage(
          id: '2', content: 'Trigonometriya formulasini eslatib yuboring',
          isAi: false, timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          id: '3',
          content: 'Albatta! Eng asosiysi — Pifagor ayniyati:\n\nsin²(α) + cos²(α) = 1\n\nBoshqa yana qaysi formulalar kerak: burchaklar yig\'indisimi yoki ikki hissalangan burchakmi?',
          isAi: true, timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          codeBlocks: ['sin²(α) + cos²(α) = 1'],
        ),
      ];

  // ─── Today Tasks ─────────────────────────────────────────────────────────
  static final List<TaskModel> todayTasks = [
    const TaskModel(id: '1', title: 'Kimyo testi', subject: 'Kimyo', subjectIcon: '🧪',
        duration: 5, xpReward: 25, isCompleted: false, type: TaskType.test),
    const TaskModel(id: '2', title: 'Fizika darsi', subject: 'Fizika', subjectIcon: '⚡',
        duration: 15, xpReward: 60, isCompleted: false, type: TaskType.lesson),
  ];

  // ─── Weekly activity ─────────────────────────────────────────────────────
  static final List<WeeklyActivity> weeklyActivity = [
    const WeeklyActivity(day: 'Du', minutes: 45),
    const WeeklyActivity(day: 'Se', minutes: 30),
    const WeeklyActivity(day: 'Che', minutes: 60),
    const WeeklyActivity(day: 'Pay', minutes: 20),
    const WeeklyActivity(day: 'Jum', minutes: 50),
    const WeeklyActivity(day: 'Sha', minutes: 35),
    const WeeklyActivity(day: 'Yak', minutes: 0),
  ];

  // ─── Students (teacher view) ──────────────────────────────────────────────
  static List<StudentModel> get students => [
        StudentModel(
          id: '1', name: 'Asadbek Aliev', avatarUrl: '', attendance: 0.94,
          score: 86.4, grade: '10-A', subject: 'Matematika + Fizika',
          talentLevel: TalentLevel.advanced, aptitudeType: 'Matematik',
          subjectScores: {'Matematika': 0.92, 'Fizika': 0.88, 'Kimyo': 0.75},
          needsAttention: false,
          recentResults: _sampleResults('Asadbek', 0.88),
        ),
        StudentModel(
          id: '2', name: 'Zilola Karimova', avatarUrl: '', attendance: 0.91,
          score: 84.1, grade: '10-A', subject: 'Matematika',
          talentLevel: TalentLevel.proficient, aptitudeType: 'Analitik',
          subjectScores: {'Matematika': 0.85, 'Fizika': 0.70, 'Ingliz tili': 0.90},
          needsAttention: false,
          recentResults: _sampleResults('Zilola', 0.78),
        ),
        StudentModel(
          id: '3', name: 'Bekzod Umarov', avatarUrl: '', attendance: 0.78,
          score: 62.4, grade: '10-A', subject: 'Fizika',
          talentLevel: TalentLevel.developing, aptitudeType: 'Izchil o\'rganuvchi',
          subjectScores: {'Matematika': 0.60, 'Fizika': 0.65, 'Tarix': 0.75},
          needsAttention: true,
          recentResults: _sampleResults('Bekzod', 0.55),
        ),
        StudentModel(
          id: '4', name: 'Malika Yusupova', avatarUrl: '', attendance: 0.97,
          score: 94.2, grade: '10-A', subject: 'Barcha fanlar',
          talentLevel: TalentLevel.gifted, aptitudeType: 'Matematik',
          subjectScores: {'Matematika': 0.96, 'Fizika': 0.94, 'Kimyo': 0.92, 'Ingliz tili': 0.95},
          needsAttention: false,
          recentResults: _sampleResults('Malika', 0.95),
        ),
        StudentModel(
          id: '5', name: 'Jasur Rahimov', avatarUrl: '', attendance: 0.65,
          score: 48.0, grade: '10-A', subject: 'Matematika',
          talentLevel: TalentLevel.beginner, aptitudeType: 'Rivojlanmoqda',
          subjectScores: {'Matematika': 0.45, 'Fizika': 0.50, 'Tarix': 0.60},
          needsAttention: true,
          recentResults: _sampleResults('Jasur', 0.42),
        ),
      ];

  static List<QuizResult> _sampleResults(String name, double avgAccuracy) {
    final now = DateTime.now();
    return List.generate(5, (i) {
      final correct = (10 * (avgAccuracy + (i % 3 - 1) * 0.05)).round().clamp(0, 10);
      return QuizResult(
        id: '${name}_$i',
        subject: 'Matematika',
        topic: 'Trigonometriya',
        totalQuestions: 10,
        correctAnswers: correct,
        xpEarned: correct * 50,
        timeSpentSeconds: 180 + i * 20,
        completedAt: now.subtract(Duration(days: i * 2)),
        questionResults: List.generate(10, (j) => QuestionResult(
          questionId: 'q${j + 1}',
          selectedAnswer: j < correct ? 0 : 1,
          correctAnswer: 0,
          isCorrect: j < correct,
          timeSpentSeconds: 18,
        )),
        talentAnalysis: const TalentAnalysis(
          level: TalentLevel.developing, summary: '',
          strengths: [], improvements: [], recommendations: [],
          skillScores: {}, aptitudeType: '',
        ),
      );
    });
  }

  // ─── Subject Tasks (fan bo'yicha topshiriqlar) ───────────────────────────
  static final Map<String, List<SubjectTaskModel>> subjectTasks = {
    '1': [ // Matematika
      SubjectTaskModel(
        id: 't1', lessonId: '1',
        title: '3-Mavzu: Sinus va Kosinus funksiyalari',
        subtitle: 'Birlik aylanada funksiyalar...',
        type: SubjectTaskType.video,
        progress: 0.70,
      ),
      SubjectTaskModel(
        id: 't2', lessonId: '1',
        title: '2-Mavzu: Sinus va test',
        subtitle: 'Birlik aylanada funksiyalar va reaksiyalar ko\'ring!',
        type: SubjectTaskType.article,
        progress: 0.80,
      ),
      SubjectTaskModel(
        id: 't3', lessonId: '1',
        title: 'Trigonometriya Test 1',
        subtitle: 'Due dau: 11. 22, 2023',
        type: SubjectTaskType.test,
        dueDate: '11. 22, 2023',
      ),
      SubjectTaskModel(
        id: 't4', lessonId: '1',
        title: 'Uyga vazifa 5',
        subtitle: 'Due dau: 15. Jul. 2023',
        type: SubjectTaskType.homework,
        dueDate: '15. Jul. 2023',
      ),
    ],
    '2': [ // Fizika
      SubjectTaskModel(
        id: 'f1', lessonId: '1',
        title: '1-Mavzu: Mexanika asoslari',
        subtitle: 'Harakat qonunlari va kuchlar...',
        type: SubjectTaskType.video,
        progress: 0.50,
      ),
      SubjectTaskModel(
        id: 'f2', lessonId: '1',
        title: 'Termodinamika Test',
        subtitle: 'Due dau: 20. Nov. 2023',
        type: SubjectTaskType.test,
        dueDate: '20. Nov. 2023',
      ),
    ],
    '3': [ // Kimyo
      SubjectTaskModel(
        id: 'k1', lessonId: '1',
        title: '1-Mavzu: Atom tuzilishi',
        subtitle: 'Proton, neytron va elektronlar...',
        type: SubjectTaskType.video,
        progress: 0.90,
      ),
      SubjectTaskModel(
        id: 'k2', lessonId: '1',
        title: 'Organik kimyo mashqlari',
        subtitle: 'Due dau: 05. Dec. 2023',
        type: SubjectTaskType.homework,
        dueDate: '05. Dec. 2023',
      ),
    ],
    '4': [ // Ingliz tili
      SubjectTaskModel(
        id: 'i1', lessonId: '1',
        title: '1-Mavzu: Grammar asoslari',
        subtitle: 'Present Simple va Present Continuous...',
        type: SubjectTaskType.article,
        progress: 0.30,
      ),
      SubjectTaskModel(
        id: 'i2', lessonId: '1',
        title: 'Vocabulary Test',
        subtitle: 'Due dau: 01. Jan. 2024',
        type: SubjectTaskType.test,
        dueDate: '01. Jan. 2024',
      ),
    ],
    '5': [ // Tarix
      SubjectTaskModel(
        id: 'ta1', lessonId: '1',
        title: '1-Mavzu: Qadimgi Sharq',
        subtitle: 'Mesopotamiya va Misr sivilizatsiyalari...',
        type: SubjectTaskType.video,
        progress: 0.60,
      ),
    ],
  };

  // ─── Subject Topic Groups (fan bo'yicha mavzular) ─────────────────────────
  static final Map<String, List<TopicGroupModel>> subjectTopicGroups = {
    '1': [ // Matematika
      TopicGroupModel(
        id: 'tg1', lessonId: '1',
        title: 'Trigonometriya asoslari',
        subtitle: 'Sinus, kosinus va tangens...',
        type: TopicType.video,
        progress: 0.70,
      ),
      TopicGroupModel(
        id: 'tg2', lessonId: '1',
        title: 'Sinuslar va Kosinuslar',
        subtitle: 'Teoremalar va amaliy misollar...',
        type: TopicType.article,
        progress: 0.80,
      ),
      TopicGroupModel(
        id: 'tg3', lessonId: '1',
        title: 'Trigonometrik tenglamalar',
        subtitle: 'Murakkab tenglamalarni yechish...',
        type: TopicType.video,
      ),
      TopicGroupModel(
        id: 'tg4', lessonId: '1',
        title: 'Algebra: Kvadrat tenglamalar',
        subtitle: 'Diskriminant va yechimlar...',
        type: TopicType.practice,
        progress: 0.40,
      ),
      TopicGroupModel(
        id: 'tg5', lessonId: '1',
        title: 'Geometriya: Uchburchaklar',
        subtitle: 'Uchburchak turlari va xossalari...',
        type: TopicType.video,
        progress: 1.0,
      ),
    ],
    '2': [ // Fizika
      TopicGroupModel(
        id: 'fg1', lessonId: '1',
        title: 'Mexanika asoslari',
        subtitle: 'Nyuton qonunlari va harakat...',
        type: TopicType.video,
        progress: 0.50,
      ),
      TopicGroupModel(
        id: 'fg2', lessonId: '1',
        title: 'Termodinamika',
        subtitle: 'Issiqlik va energiya almashish...',
        type: TopicType.article,
      ),
      TopicGroupModel(
        id: 'fg3', lessonId: '1',
        title: 'Elektr va Magnetizm',
        subtitle: 'Zaryad, tok va maydon...',
        type: TopicType.video,
        progress: 0.20,
      ),
    ],
    '3': [ // Kimyo
      TopicGroupModel(
        id: 'kg1', lessonId: '1',
        title: 'Atom tuzilishi',
        subtitle: 'Electron, proton, neytron...',
        type: TopicType.video,
        progress: 1.0,
      ),
      TopicGroupModel(
        id: 'kg2', lessonId: '1',
        title: 'Kimyoviy reaksiyalar',
        subtitle: 'Reaksiya turlari va tenglamalar...',
        type: TopicType.practice,
        progress: 0.70,
      ),
      TopicGroupModel(
        id: 'kg3', lessonId: '1',
        title: 'Organik kimyo',
        subtitle: 'Uglevodorodlar va hosilalari...',
        type: TopicType.article,
        progress: 0.60,
      ),
    ],
    '4': [ // Ingliz tili
      TopicGroupModel(
        id: 'ig1', lessonId: '1',
        title: 'Grammar asoslari',
        subtitle: 'Zamona shakllarini o\'rganish...',
        type: TopicType.article,
        progress: 0.30,
      ),
      TopicGroupModel(
        id: 'ig2', lessonId: '1',
        title: 'Vocabulary Building',
        subtitle: '500+ eng ko\'p ishlatiladigan so\'zlar...',
        type: TopicType.practice,
      ),
    ],
    '5': [ // Tarix
      TopicGroupModel(
        id: 'tag1', lessonId: '1',
        title: 'Qadimgi Sharq sivilizatsiyalari',
        subtitle: 'Mesopotamiya, Misr va Hind...',
        type: TopicType.video,
        progress: 0.80,
      ),
      TopicGroupModel(
        id: 'tag2', lessonId: '1',
        title: 'O\'rta asrlar Evropasi',
        subtitle: 'Feodalizm va Xaçli yurishlar...',
        type: TopicType.article,
        progress: 0.40,
      ),
    ],
  };

  // ─── Subject Roadmaps ─────────────────────────────────────────────────────
  static final Map<String, SubjectRoadmapModel> subjectRoadmaps = {
    '1': const SubjectRoadmapModel( // Matematika
      subjectId: '1',
      subjectName: 'Matematika',
      totalXP: 2650,
      earnedXP: 1240,
      topics: [
        RoadmapTopicModel(
          id: 'algebra',
          title: 'Algebra',
          icon: '📊',
          status: RoadmapTopicStatus.completed,
          xpReward: 500,
          lessonCount: 8,
          completedLessons: 8,
        ),
        RoadmapTopicModel(
          id: 'geometriya',
          title: 'Geometriya',
          icon: '📐',
          status: RoadmapTopicStatus.completed,
          xpReward: 400,
          lessonCount: 6,
          completedLessons: 6,
        ),
        RoadmapTopicModel(
          id: 'trigonometriya',
          title: 'Trigonometriya',
          icon: '🔺',
          status: RoadmapTopicStatus.current,
          xpReward: 350,
          lessonCount: 5,
          completedLessons: 2,
          specialTag: 'JORIY',
        ),
        RoadmapTopicModel(
          id: 'calculus',
          title: 'Calculus',
          icon: '∫',
          status: RoadmapTopicStatus.locked,
          xpReward: 750,
          lessonCount: 10,
          completedLessons: 0,
        ),
        RoadmapTopicModel(
          id: 'bonus',
          title: '1500 XP',
          icon: '🏆',
          status: RoadmapTopicStatus.bonus,
          xpReward: 1500,
          lessonCount: 0,
          completedLessons: 0,
          isMilestone: true,
        ),
        RoadmapTopicModel(
          id: 'matritsalar',
          title: 'Matritsalar',
          icon: '🔢',
          status: RoadmapTopicStatus.locked,
          xpReward: 650,
          lessonCount: 8,
          completedLessons: 0,
        ),
      ],
    ),
    '2': const SubjectRoadmapModel( // Fizika
      subjectId: '2',
      subjectName: 'Fizika',
      totalXP: 2200,
      earnedXP: 450,
      topics: [
        RoadmapTopicModel(
          id: 'mexanika',
          title: 'Mexanika',
          icon: '⚙️',
          status: RoadmapTopicStatus.current,
          xpReward: 400,
          lessonCount: 6,
          completedLessons: 3,
          specialTag: 'JORIY',
        ),
        RoadmapTopicModel(
          id: 'termodinamika',
          title: 'Termodinamika',
          icon: '🌡️',
          status: RoadmapTopicStatus.locked,
          xpReward: 350,
          lessonCount: 5,
          completedLessons: 0,
        ),
        RoadmapTopicModel(
          id: 'elektr',
          title: 'Elektr va Magnetizm',
          icon: '⚡',
          status: RoadmapTopicStatus.locked,
          xpReward: 500,
          lessonCount: 7,
          completedLessons: 0,
        ),
        RoadmapTopicModel(
          id: 'optika',
          title: 'Optika',
          icon: '🔍',
          status: RoadmapTopicStatus.locked,
          xpReward: 300,
          lessonCount: 4,
          completedLessons: 0,
        ),
        RoadmapTopicModel(
          id: 'kvant',
          title: 'Kvant fizikasi',
          icon: '⚛️',
          status: RoadmapTopicStatus.locked,
          xpReward: 650,
          lessonCount: 8,
          completedLessons: 0,
        ),
      ],
    ),
    '3': const SubjectRoadmapModel( // Kimyo
      subjectId: '3',
      subjectName: 'Kimyo',
      totalXP: 1800,
      earnedXP: 1200,
      topics: [
        RoadmapTopicModel(
          id: 'atom',
          title: 'Atom tuzilishi',
          icon: '⚛️',
          status: RoadmapTopicStatus.completed,
          xpReward: 300,
          lessonCount: 4,
          completedLessons: 4,
        ),
        RoadmapTopicModel(
          id: 'reaksiyalar',
          title: 'Kimyoviy reaksiyalar',
          icon: '🧪',
          status: RoadmapTopicStatus.completed,
          xpReward: 400,
          lessonCount: 6,
          completedLessons: 6,
        ),
        RoadmapTopicModel(
          id: 'organik',
          title: 'Organik kimyo',
          icon: '🔬',
          status: RoadmapTopicStatus.current,
          xpReward: 350,
          lessonCount: 5,
          completedLessons: 3,
          specialTag: 'JORIY',
        ),
        RoadmapTopicModel(
          id: 'eritmalar',
          title: 'Eritmalar',
          icon: '🥤',
          status: RoadmapTopicStatus.locked,
          xpReward: 250,
          lessonCount: 3,
          completedLessons: 0,
        ),
        RoadmapTopicModel(
          id: 'elektrokimyo',
          title: 'Elektrokimyo',
          icon: '🔋',
          status: RoadmapTopicStatus.locked,
          xpReward: 500,
          lessonCount: 7,
          completedLessons: 0,
        ),
      ],
    ),
  };

  // ─── Notifications ────────────────────────────────────────────────────────
  static List<AppNotification> get notifications => [
        AppNotification(
          id: '1', title: 'Kunlik maqsad!', icon: '🎯',
          body: 'Bugun 2 ta vazifa yakunlandi. Yana 1 ta qoldi!',
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AppNotification(
          id: '2', title: 'Streak davom etmoqda 🔥', icon: '🔥',
          body: '12 kunlik streak! Bugun ham o\'qishni unutmang.',
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AppNotification(
          id: '3', title: 'Yangi dars qo\'shildi', icon: '📚',
          body: 'Trigonometriya: Kosinuslar teoremasi — 18 daqiqa.',
          time: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
}
