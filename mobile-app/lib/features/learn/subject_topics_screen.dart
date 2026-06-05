import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/subject_icon.dart';

class SubjectTopicsScreen extends StatefulWidget {
  final String subjectId;
  const SubjectTopicsScreen({super.key, required this.subjectId});

  @override
  State<SubjectTopicsScreen> createState() => _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends State<SubjectTopicsScreen>
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

  SubjectModel get _subject =>
      MockData.subjects.firstWhere((s) => s.id == widget.subjectId,
          orElse: () => MockData.subjects.first);

  @override
  Widget build(BuildContext context) {
    final subject = _subject;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (ctx, innerScrolled) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.onSurface,
              onPressed: () => context.pop(),
            ),
            title: Text(
              subject.name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                color: AppColors.onSurface,
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _SubjectTabBar(controller: _tabController),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _TasksTab(subject: subject),
            _TopicsTab(subject: subject),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Bar ────────────────────────────────────────────────────────────────
class _SubjectTabBar extends StatelessWidget {
  final TabController controller;
  const _SubjectTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        labelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
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
          Tab(text: 'Topshiriqlar'),
          Tab(text: 'Mavzular'),
        ],
      ),
    );
  }
}

// ─── Tasks Tab ───────────────────────────────────────────────────────────────
class _TasksTab extends StatelessWidget {
  final SubjectModel subject;
  const _TasksTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    final tasks = MockData.subjectTasks[subject.id] ?? [];
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Interactive banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _InteractiveBanner(subject: subject)
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.05, end: 0),
          ),
        ),
        // Tasks list
        if (tasks.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Hozircha topshiriqlar yo\'q',
                  style: AppTextStyles.bodySm,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _TaskCard(task: tasks[i], subject: subject)
                    .animate(delay: (60 + i * 60).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.06, end: 0),
              ),
              childCount: tasks.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _InteractiveBanner extends StatelessWidget {
  final SubjectModel subject;
  const _InteractiveBanner({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interaktiv ${subject.topics.isNotEmpty ? subject.topics.first : subject.name}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bosing va interaktiv mashqni sinab ko\'ring!',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              textStyle:
                  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: const Text('Try It!'),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final SubjectTaskModel task;
  final SubjectModel subject;
  const _TaskCard({required this.task, required this.subject});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/lesson/${task.lessonId}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBg(task.type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconData(task.type),
                  color: _iconColor(task.type), size: 22),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.labelMd),
                  const SizedBox(height: 3),
                  Text(task.subtitle,
                      style: AppTextStyles.bodySm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (task.progress != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: task.progress,
                              minHeight: 5,
                              backgroundColor: AppColors.outlineVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _progressColor(subject.color)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(task.progress! * 100).round()}% Tugallandi',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _progressColor(subject.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SubjectIcon(subject: subject, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Due dau: ${task.dueDate}',
                          style: AppTextStyles.labelSm,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Color _iconBg(SubjectTaskType type) {
    switch (type) {
      case SubjectTaskType.video:
        return AppColors.primaryContainer.withValues(alpha: 0.12);
      case SubjectTaskType.article:
        return AppColors.secondary.withValues(alpha: 0.12);
      case SubjectTaskType.test:
        return AppColors.tertiary.withValues(alpha: 0.12);
      case SubjectTaskType.homework:
        return Colors.orange.withValues(alpha: 0.12);
    }
  }

  Color _iconColor(SubjectTaskType type) {
    switch (type) {
      case SubjectTaskType.video:
        return AppColors.primaryContainer;
      case SubjectTaskType.article:
        return AppColors.secondary;
      case SubjectTaskType.test:
        return AppColors.tertiary;
      case SubjectTaskType.homework:
        return Colors.orange;
    }
  }

  IconData _iconData(SubjectTaskType type) {
    switch (type) {
      case SubjectTaskType.video:
        return Icons.play_circle_outline_rounded;
      case SubjectTaskType.article:
        return Icons.article_outlined;
      case SubjectTaskType.test:
        return Icons.quiz_outlined;
      case SubjectTaskType.homework:
        return Icons.assignment_outlined;
    }
  }

  Color _progressColor(SubjectColor color) {
    switch (color) {
      case SubjectColor.blue:
        return AppColors.primaryContainer;
      case SubjectColor.orange:
        return Colors.orange;
      case SubjectColor.green:
        return AppColors.secondary;
      case SubjectColor.purple:
        return Colors.purple;
      case SubjectColor.teal:
        return Colors.teal;
      case SubjectColor.yellow:
        return Colors.amber;
    }
  }
}

// ─── Topics Tab ──────────────────────────────────────────────────────────────
class _TopicsTab extends StatelessWidget {
  final SubjectModel subject;
  const _TopicsTab({required this.subject});

  @override
  Widget build(BuildContext context) {
    final topicGroups = MockData.subjectTopicGroups[subject.id] ?? [];
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _SubjectProgressHeader(subject: subject)
                .animate()
                .fadeIn(duration: 350.ms),
          ),
        ),
        if (topicGroups.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('Mavzular topilmadi', style: AppTextStyles.bodySm),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _TopicGroupCard(
                  group: topicGroups[i],
                  subject: subject,
                  index: i,
                )
                    .animate(delay: (60 + i * 70).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.06, end: 0),
              ),
              childCount: topicGroups.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _SubjectProgressHeader extends StatelessWidget {
  final SubjectModel subject;
  const _SubjectProgressHeader({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer,
            AppColors.primaryContainer.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SubjectIcon(subject: subject, size: 52, large: true),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.completedLessons}/${subject.totalLessons} mavzu yakunlandi',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(subject.progress * 100).round()}%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicGroupCard extends StatelessWidget {
  final TopicGroupModel group;
  final SubjectModel subject;
  final int index;
  const _TopicGroupCard(
      {required this.group, required this.subject, required this.index});

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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/lesson/${group.lessonId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _topicIcon(group.type),
                    color: AppColors.primaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}-Mavzu: ${group.title}',
                        style: AppTextStyles.labelMd,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        group.subtitle,
                        style: AppTextStyles.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppColors.outline),
              ],
            ),
            if (group.progress != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: group.progress,
                        minHeight: 5,
                        backgroundColor: AppColors.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _progressColor(subject.color),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(group.progress! * 100).round()}% Tugallandi',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _progressColor(subject.color),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _topicIcon(TopicType type) {
    switch (type) {
      case TopicType.video:
        return Icons.play_circle_outline_rounded;
      case TopicType.article:
        return Icons.article_outlined;
      case TopicType.practice:
        return Icons.edit_note_rounded;
    }
  }

  Color _progressColor(SubjectColor color) {
    switch (color) {
      case SubjectColor.blue:
        return AppColors.primaryContainer;
      case SubjectColor.orange:
        return Colors.orange;
      case SubjectColor.green:
        return AppColors.secondary;
      case SubjectColor.purple:
        return Colors.purple;
      case SubjectColor.teal:
        return Colors.teal;
      case SubjectColor.yellow:
        return Colors.amber;
    }
  }
}
