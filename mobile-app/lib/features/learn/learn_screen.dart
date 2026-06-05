import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/logo_widget.dart';
import '../../shared/widgets/subject_icon.dart';
import 'learning_path_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              color: AppColors.onSurface,
              onPressed: () {},
            ),
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
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                color: AppColors.onSurface,
                onPressed: () => context.push('/notifications'),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: _CustomTabBar(controller: _tabController),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            const _SubjectsTab(),
            const LearningPathScreen(),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Tab Bar ────────────────────────────────────────────────────────
class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  const _CustomTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.outline,
        indicator: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryContainer.withValues(alpha: 0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Fanlar'),
          Tab(text: "O'quv yo'li"),
        ],
      ),
    );
  }
}

// ─── Subjects Tab ──────────────────────────────────────────────────────────
class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab();

  @override
  Widget build(BuildContext context) {
    final subjects = MockData.subjects;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fanni tanlang', style: AppTextStyles.headlineLgMobile)
                    .animate()
                    .fadeIn(duration: 350.ms),
                const SizedBox(height: 4),
                Text(
                  'Bugun qaysi cho\'qni zabt etmoqchisiz? TalimZ bilan o\'rganish oson.',
                  style: AppTextStyles.bodySm,
                ).animate(delay: 60.ms).fadeIn(duration: 350.ms),
              ],
            ),
          ),
        ),

        // Subjects list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _SubjectCard(subject: subjects[i])
                  .animate(delay: (80 + i * 70).ms)
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.06, end: 0),
            ),
            childCount: subjects.length,
          ),
        ),

        // Recommended banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: _RecommendedBanner()
                .animate(delay: 500.ms)
                .fadeIn(duration: 400.ms),
          ),
        ),
      ],
    );
  }
}

// ─── Subject Card ──────────────────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              SubjectIcon(subject: subject, size: 52, large: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: AppTextStyles.labelLg),
                    const SizedBox(height: 3),
                    Text(
                      subject.description,
                      style: AppTextStyles.bodySm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Roadmap button
              GestureDetector(
                onTap: () => context.push('/subject/${subject.id}/roadmap'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/subject/${subject.id}'),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SubjectProgressBar(
                  progress: subject.progress,
                  color: subject.color,
                  height: 7,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                subject.progress >= 0.6
                    ? '${(subject.progress * 100).round()}% tugallandi'
                    : '${subject.completedLessons}/${subject.totalLessons} dars',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subject.progress >= 0.6
                      ? AppColors.secondary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Recommended Banner ────────────────────────────────────────────────────
class _RecommendedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF003FA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('Tavsiya etiladi',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
          const SizedBox(height: 10),
          Text('Matematika:\nTrigonometriya asoslari',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              )),
          const SizedBox(height: 8),
          Text(
            "Oxirgi darsingizni davom ettiring va bugun 50 ball bonusga ega bo'ling!",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.push('/lesson/1'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Davom ettirish',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryContainer,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
