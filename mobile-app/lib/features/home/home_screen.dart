import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/logo_widget.dart';
import 'widgets/daily_goal_card.dart';
import 'widgets/quick_action_grid.dart';
import 'widgets/upcoming_lesson_card.dart';
import 'widgets/today_tasks_section.dart';
import 'widgets/recommended_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final notifications = MockData.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                const SmallLogoWidget(size: 32),
                const SizedBox(width: 12),
                Text(
                  "Ta'limZ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: AppColors.onSurface,
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (notifications.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: _AvatarWidget(name: user.name),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ──────────────────────────────────────────
                  _GreetingSection(user: user)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Streak chips ──────────────────────────────────────
                  _GamificationRow(user: user)
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 16),

                  // ── Daily Goal ────────────────────────────────────────
                  const DailyGoalCard()
                      .animate(delay: 150.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 14),

                  // ── Quick Actions ─────────────────────────────────────
                  const QuickActionGrid()
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Upcoming Lesson ───────────────────────────────────
                  _SectionHeader(
                    title: 'Navbatdagi dars',
                    action: 'Hammasi',
                    onAction: () => context.go('/learn'),
                  ).animate(delay: 250.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 10),
                  const UpcomingLessonCard()
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Tip ───────────────────────────────────────────────
                  const _TipCard()
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Today tasks ───────────────────────────────────────
                  const TodayTasksSection()
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Recommended ───────────────────────────────────────
                  _SectionHeader(
                    title: 'Sizga tavsiya etiladi',
                    action: '',
                    onAction: () {},
                  ).animate(delay: 450.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 10),
                  const RecommendedSection()
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Greeting ─────────────────────────────────────────────────────────────
class _GreetingSection extends StatelessWidget {
  final dynamic user;
  const _GreetingSection({required this.user});

  String _timeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Xayrli tong';
    if (h < 17) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_timeGreeting()}, ${user.name}! 👋',
                style: AppTextStyles.headlineLgMobile,
              ),
              const SizedBox(height: 4),
              Text(
                'Yangi marralar sari tayyormisiz?',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Gamification chips ────────────────────────────────────────────────────
class _GamificationRow extends StatelessWidget {
  final dynamic user;
  const _GamificationRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(icon: '🔥', label: '${user.streak}-kunlik streak',
              color: AppColors.streakColor),
          const SizedBox(width: 8),
          _Chip(icon: '⭐', label: '${user.xp} XP',
              color: AppColors.primaryContainer),
          const SizedBox(width: 8),
          _Chip(icon: '🎓', label: user.grade,
              color: AppColors.secondary),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;
  const _SectionHeader(
      {required this.title, required this.action, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSm),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            child: Text(action,
                style: GoogleFonts.inter(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ),
      ],
    );
  }
}

// ─── Avatar ────────────────────────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final String name;
  const _AvatarWidget({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Tip Card ─────────────────────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: Text('💡', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kun maslahati',
                    style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                const SizedBox(height: 3),
                Text(
                  'Har 25 daqiqa o\'qishdan so\'ng 5 daqiqa dam olish miyangizga ma\'lumotlarni yaxshiroq eslab qolishga yordam beradi.',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
