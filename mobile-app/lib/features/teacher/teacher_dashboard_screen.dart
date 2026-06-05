import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StudentModel? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.onSurface,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Text('10-A',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    )),
                const SizedBox(width: 6),
                Text('Sinf Tahlili',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    )),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                color: AppColors.onSurface,
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.outline,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Umumiy'),
                Tab(text: 'O\'quvchilar'),
                Tab(text: 'AI Tahlil'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(),
            _StudentsTab(onSelect: (s) {
              setState(() => _selectedStudent = s);
              _tabController.animateTo(2);
            }),
            _AiInsightsTab(selectedStudent: _selectedStudent),
          ],
        ),
      ),
    );
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stat cards
          Row(children: [
            Expanded(
              child: _StatCard(
                title: 'O\'rtacha davomat',
                value: '92%',
                subtitle: 'Yuqori',
                icon: '📋',
                badge: '+2.4% o\'tgan oy',
                positive: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Sinf faolligi',
                value: '85%',
                subtitle: 'Eng yuqori: Seshanba',
                icon: '⚡',
                badge: 'Aralashish kerak',
                positive: false,
              ),
            ),
          ]).animate(delay: 50.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _StatCard(
                title: 'Bajarilmagan',
                value: '24',
                subtitle: 'bugungi topshiriqlar',
                icon: '📌',
                badge: '12 ta Kritik',
                positive: false,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                title: 'Iqtidorli',
                value: '${MockData.students.where((s) => s.talentLevel == TalentLevel.gifted || s.talentLevel == TalentLevel.advanced).length} ta',
                subtitle: 'o\'quvchi',
                icon: '💎',
                badge: 'Olimpiadaga tavsiya',
                positive: true,
              ),
            ),
          ]).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // Weekly chart
          _WeeklyChart().animate(delay: 150.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // Top students
          _TopStudentsCard().animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 16),

          // Attention needed
          _AttentionCard().animate(delay: 250.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String icon;
  final String badge;
  final bool positive;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final bColor = positive ? AppColors.secondary : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: bColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: bColor,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineMd),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.labelSm),
          Text(subtitle,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.outline)),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Haftalik', style: AppTextStyles.labelLg),
                Text('Sinf natijalari fan bo\'yicha',
                    style: AppTextStyles.labelSm),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Text('So\'nggi 7 kun', style: AppTextStyles.labelSm),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.outline),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: AppColors.outlineVariant, strokeWidth: 0.8),
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      const d = ['Du', 'Se', 'Che', 'Pay', 'Jum', 'Sha', 'Yak'];
                      final i = v.toInt();
                      return i < d.length
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(d[i], style: AppTextStyles.labelSm))
                          : const Text('');
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0,70),FlSpot(1,82),FlSpot(2,75),FlSpot(3,88),FlSpot(4,80),FlSpot(5,91),FlSpot(6,78)],
                  isCurved: true,
                  color: AppColors.primaryContainer,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  ),
                ),
                LineChartBarData(
                  spots: const [FlSpot(0,60),FlSpot(1,65),FlSpot(2,70),FlSpot(3,72),FlSpot(4,68),FlSpot(5,75),FlSpot(6,80)],
                  isCurved: true,
                  color: AppColors.secondary,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  dashArray: [4, 4],
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            )),
          ),
          const SizedBox(height: 10),
          Row(children: [
            _ChartLegend(color: AppColors.primaryContainer, label: 'Matematika'),
            const SizedBox(width: 16),
            _ChartLegend(color: AppColors.secondary, label: 'Fizika'),
          ]),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 3, color: color,
            margin: const EdgeInsets.only(right: 6)),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

class _TopStudentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MockData.students
        .where((s) =>
            s.talentLevel == TalentLevel.gifted ||
            s.talentLevel == TalentLevel.advanced)
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top O\'quvchilar', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          ...top.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: e.key == 0
                          ? AppColors.goldColor.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        e.key == 0 ? '🥇' : e.key == 1 ? '🥈' : '🥉',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _AvatarCircle(name: e.value.name),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value.name, style: AppTextStyles.labelMd),
                        Text('O\'rtacha: ${e.value.score.toStringAsFixed(1)}',
                            style: AppTextStyles.labelSm),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(e.value.talentLevel.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        )),
                  ),
                ]),
              )),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final atRisk = MockData.students.where((s) => s.needsAttention).toList();
    if (atRisk.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('⚠️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('E\'tibor talab qiladi', style: AppTextStyles.labelLg),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${atRisk.length} o\'quvchi',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  )),
            ),
          ]),
          const SizedBox(height: 12),
          ...atRisk.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  _AvatarCircle(name: s.name, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: AppTextStyles.labelMd),
                        Text('Davomat: ${(s.attendance * 100).toInt()}% • Ball: ${s.score.toStringAsFixed(0)}',
                            style: AppTextStyles.labelSm),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Yordam',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ]),
              )),
        ],
      ),
    );
  }
}

// ─── Students Tab ─────────────────────────────────────────────────────────
class _StudentsTab extends StatelessWidget {
  final Function(StudentModel) onSelect;
  const _StudentsTab({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final students = MockData.students;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, state) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = students[i];
        return GestureDetector(
          onTap: () => onSelect(s),
          child: _StudentRow(student: s)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 350.ms)
              .slideX(begin: 0.05, end: 0),
        );
      },
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentModel student;
  const _StudentRow({required this.student});

  Color get _levelColor {
    switch (student.talentLevel) {
      case TalentLevel.gifted:
        return AppColors.goldColor;
      case TalentLevel.advanced:
        return AppColors.primaryContainer;
      case TalentLevel.proficient:
        return AppColors.secondary;
      case TalentLevel.developing:
        return AppColors.tertiaryContainer;
      case TalentLevel.beginner:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: student.needsAttention
              ? AppColors.error.withValues(alpha: 0.30)
              : AppColors.outlineVariant,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          _AvatarCircle(
              name: student.name,
              color: student.needsAttention ? AppColors.error : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child:
                            Text(student.name, style: AppTextStyles.labelMd)),
                    if (student.needsAttention)
                      const Text('⚠️', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(student.subject, style: AppTextStyles.labelSm),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: student.score / 100,
                        minHeight: 5,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${student.score.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _levelColor,
                      )),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _levelColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(student.talentLevel.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _levelColor,
                    )),
              ),
              const SizedBox(height: 4),
              Text('${(student.attendance * 100).toInt()}% davomat',
                  style: AppTextStyles.labelSm),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AI Insights Tab ─────────────────────────────────────────────────────
class _AiInsightsTab extends StatelessWidget {
  final StudentModel? selectedStudent;
  const _AiInsightsTab({this.selectedStudent});

  @override
  Widget build(BuildContext context) {
    final student = selectedStudent ?? MockData.students.first;
    final analysis = AiAnalysisService.analyzeStudentProfile(
      results: student.recentResults,
      studentName: student.name,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student selector hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '"O\'quvchilar" tabidan o\'quvchi tanlang',
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                ),
              ),
            ]),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 14),

          // Student header
          _StudentInsightHeader(student: student, analysis: analysis)
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 14),

          // AI summary
          _AiSummaryBox(analysis: analysis)
              .animate(delay: 150.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 14),

          // Subject radar
          _SubjectRadar(student: student)
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 14),

          // Skills
          _SkillsPanel(analysis: analysis)
              .animate(delay: 250.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 14),

          // Recommendations
          _TeacherRecommendations(analysis: analysis, student: student)
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 14),

          // Performance trend
          _PerformanceTrend(student: student)
              .animate(delay: 350.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _StudentInsightHeader extends StatelessWidget {
  final StudentModel student;
  final TalentAnalysis analysis;
  const _StudentInsightHeader({required this.student, required this.analysis});

  Color get _levelColor {
    switch (student.talentLevel) {
      case TalentLevel.gifted:
        return AppColors.goldColor;
      case TalentLevel.advanced:
        return AppColors.primaryContainer;
      case TalentLevel.proficient:
        return AppColors.secondary;
      case TalentLevel.developing:
        return AppColors.tertiaryContainer;
      case TalentLevel.beginner:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _levelColor.withValues(alpha: 0.12),
            _levelColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _levelColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _AvatarCircle(name: student.name, color: _levelColor, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.headlineSm),
                const SizedBox(height: 3),
                Text('${student.grade} • ${student.subject}',
                    style: AppTextStyles.bodySm),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${student.talentLevel.icon} ${student.talentLevel.label}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _levelColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(analysis.aptitudeType,
                      style: AppTextStyles.labelSm),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${student.score.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _levelColor,
                  )),
              Text('ball', style: AppTextStyles.labelSm),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiSummaryBox extends StatelessWidget {
  final TalentAnalysis analysis;
  const _AiSummaryBox({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text('AI Iqtidor Tahlili',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ]),
          const SizedBox(height: 10),
          Text(analysis.summary,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.6,
              )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _WhiteChip("Yo'nalish: ${analysis.aptitudeType}"),
              _WhiteChip(() {
                final e = analysis.skillScores.entries.first;
                return '${e.key}: ${(e.value * 100).toInt()}%';
              }()),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  final String label;
  const _WhiteChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class _SubjectRadar extends StatelessWidget {
  final StudentModel student;
  const _SubjectRadar({required this.student});

  @override
  Widget build(BuildContext context) {
    final scores = student.subjectScores;
    if (scores.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Fan bo'yicha tahlil", style: AppTextStyles.labelLg),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: RadarChart(RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderColor: AppColors.primaryContainer,
                  borderWidth: 2.0,
                  dataEntries: scores.values
                      .map((v) => RadarEntry(value: v * 100))
                      .toList(),
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: BorderSide(
                  color: AppColors.outlineVariant, width: 1),
              tickBorderData: BorderSide(
                  color: AppColors.outlineVariant, width: 0.5),
              ticksTextStyle: GoogleFonts.inter(
                  fontSize: 8, color: AppColors.outline),
              getTitle: (index, angle) {
                final keys = scores.keys.toList();
                return RadarChartTitle(
                    text: index < keys.length ? keys[index] : '',
                    angle: angle);
              },
              tickCount: 4,
            )),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: scores.entries
                .map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(
                            '${e.key} ${(e.value * 100).toInt()}%',
                            style: AppTextStyles.labelSm),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillsPanel extends StatelessWidget {
  final TalentAnalysis analysis;
  const _SkillsPanel({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ko\'nikmalar', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          ...analysis.skillScores.entries.map((e) {
            final color = e.value >= 0.75
                ? AppColors.secondary
                : e.value >= 0.5
                    ? AppColors.tertiaryContainer
                    : AppColors.error;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTextStyles.labelMd),
                      Text('${(e.value * 100).toInt()}%',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: e.value),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, child) => ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 7,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TeacherRecommendations extends StatelessWidget {
  final TalentAnalysis analysis;
  final StudentModel student;
  const _TeacherRecommendations(
      {required this.analysis, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎯', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text('O\'qituvchiga tavsiyalar', style: AppTextStyles.labelLg),
          ]),
          const SizedBox(height: 12),
          ...analysis.recommendations.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(e.value, style: AppTextStyles.bodyMd)),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          // Olimpiad recommendation if gifted
          if (student.talentLevel == TalentLevel.gifted ||
              student.talentLevel == TalentLevel.advanced)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.goldColor.withValues(alpha: 0.30)),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Olimpiada tavsiyasi',
                            style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.goldColor)),
                        const SizedBox(height: 3),
                        Text(
                          '${student.name} Olimpiada musobaqasiga tayyorlash uchun qo\'shimcha mashg\'ulotlar tashkil etish tavsiya etiladi.',
                          style: AppTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PerformanceTrend extends StatelessWidget {
  final StudentModel student;
  const _PerformanceTrend({required this.student});

  @override
  Widget build(BuildContext context) {
    if (student.recentResults.isEmpty) return const SizedBox.shrink();

    final sorted = [...student.recentResults]
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Natija tendensiyasi', style: AppTextStyles.labelLg),
          const SizedBox(height: 4),
          Text('So\'nggi ${sorted.length} ta test',
              style: AppTextStyles.labelSm),
          const SizedBox(height: 14),
          SizedBox(
            height: 90,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: sorted.asMap().entries.map((e) =>
                      FlSpot(e.key.toDouble(), e.value.percentage)).toList(),
                  isCurved: true,
                  color: AppColors.primaryContainer,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, pct, bar, idx) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.primaryContainer,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────
class _AvatarCircle extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const _AvatarCircle(
      {required this.name,
      this.color = AppColors.primary,
      this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
