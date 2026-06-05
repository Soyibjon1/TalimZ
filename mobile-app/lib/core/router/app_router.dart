import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/learn/learn_screen.dart';
import '../../features/learn/lesson_screen.dart';
import '../../features/learn/subject_roadmap_screen.dart';
import '../../features/ai_chat/ai_chat_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/quiz/quiz_screen.dart';
import '../../features/onboarding/landing_screen.dart';
import '../../features/teacher/teacher_dashboard_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/learn/subject_topics_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/quiz/:subject',
      builder: (context, state) =>
          QuizScreen(subject: state.pathParameters['subject'] ?? 'Matematika'),
    ),
    GoRoute(
      path: '/lesson/:id',
      builder: (context, state) =>
          LessonScreen(lessonId: state.pathParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/teacher',
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/subject/:id',
      builder: (context, state) =>
          SubjectTopicsScreen(subjectId: state.pathParameters['id'] ?? '1'),
    ),
    GoRoute(
      path: '/subject/:id/roadmap',
      builder: (context, state) =>
          SubjectRoadmapScreen(subjectId: state.pathParameters['id'] ?? '1'),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
        GoRoute(path: '/ai', builder: (context, state) => const AiChatScreen()),
        GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);
