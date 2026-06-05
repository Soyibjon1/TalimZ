import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/logo_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProv = context.watch<AppProvider>();
    final user = appProv.user;
    final analysis = appProv.latestAnalysis;
    final weekly = MockData.weeklyActivity;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
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
                    fontSize: 20,
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
                onPressed: () {},
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                children: [
                  // Streak header
                  _StreakHeader(streak: user.streak)
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),

                  // Level card
                  _LevelCard(user: user)
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),

                  // XP + stats
                  _StatsGrid(user: user, appProv: appProv)
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),

                  // Weekly activity
                  _WeeklyCard(weekly: weekly)
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),

                  // AI tahlil (if any)
                  if (analysis != null)
                    _AiProgressBanner(analysis: analysis)
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 400.ms),
                  if (analysis != null) const SizedBox(height: 14),

                  // Radar chart
                  _RadarCard()
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),

                  // Achievements
                  _AchievementsSection(user: user)
                      .animate(delay: 280.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 14),

                  // Teacher praise card
                  _TeacherCard()
                      .animate(delay: 320.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakHeader extends StatelessWidget {
  final int streak;
  const _StreakHeader({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$streak kun',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.streakColor)),
            Text('Faollik davomiyligi', style: AppTextStyles.labelSm),
          ],
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final dynamic user;
  const _LevelCard({required this.user});

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level ${user.level}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    Text('Bilimdon daraja',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.80))),
                  ],
                ),
              ),
              Text('${(user.xp / 1000).toStringAsFixed(1)}K XP',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.80))),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.75),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, v, child) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.20),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('75% tamomlandi',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.80))),
              Text('Keyingi darajagacha 580 XP',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.80))),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final dynamic user;
  final AppProvider appProv;
  const _StatsGrid({required this.user, required this.appProv});

  @override
  Widget build(BuildContext context) {
    final totalXp = user.xp + appProv.totalXpSession;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Umumiy XP', style: AppTextStyles.labelSm),
                const SizedBox(height: 6),
                Text(
                  '$totalXp',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryContainer),
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('+12%',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary)),
                  ),
                  const SizedBox(width: 6),
                  Text('bu hafta', style: AppTextStyles.labelSm),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _InfoCard(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Text('📚', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Darslar', style: AppTextStyles.labelSm),
                    Text('${user.completedTests}', style: AppTextStyles.labelLg),
                  ]),
                ]),
              ),
              const SizedBox(height: 8),
              _InfoCard(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Text('⏱️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Soat', style: AppTextStyles.labelSm),
                    Text('124', style: AppTextStyles.labelLg),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _InfoCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  final List<WeeklyActivity> weekly;
  const _WeeklyCard({required this.weekly});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Haftalik faollik', style: AppTextStyles.labelLg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(children: [
                  Text('Oxirgi 7 kun', style: AppTextStyles.labelSm),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppColors.outline),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 70,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      return i < weekly.length
                          ? Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(weekly[i].day,
                                  style: AppTextStyles.labelSm))
                          : const Text('');
                    },
                    reservedSize: 24,
                  ),
                ),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: weekly.asMap().entries.map((e) {
                final isToday = e.key == 4;
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: e.value.minutes.toDouble(),
                    color: isToday
                        ? AppColors.primaryContainer
                        : e.value.minutes > 0
                            ? AppColors.primary.withValues(alpha: 0.45)
                            : AppColors.surfaceContainerHigh,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ]);
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }
}

class _AiProgressBanner extends StatelessWidget {
  final TalentAnalysis analysis;
  const _AiProgressBanner({required this.analysis});

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
            Text('AI Tahlil — ${analysis.aptitudeType} tipi',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 10),
          Text(analysis.summary,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.5)),
          const SizedBox(height: 10),
          Row(
            children: analysis.skillScores.entries.take(3).map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${e.key}: ${(e.value * 100).toInt()}%',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("O'dashtirish", style: AppTextStyles.labelLg),
          const SizedBox(height: 4),
          Text('Fan bo\'yicha tahlil', style: AppTextStyles.labelSm),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: RadarChart(RadarChartData(
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                  borderColor: AppColors.primaryContainer,
                  borderWidth: 2,
                  dataEntries: const [
                    RadarEntry(value: 92),
                    RadarEntry(value: 78),
                    RadarEntry(value: 80),
                    RadarEntry(value: 65),
                    RadarEntry(value: 72),
                  ],
                ),
              ],
              radarBackgroundColor: Colors.transparent,
              borderData: FlBorderData(show: false),
              radarBorderData: const BorderSide(color: AppColors.outlineVariant),
              tickBorderData: const BorderSide(color: AppColors.outlineVariant),
              ticksTextStyle: GoogleFonts.inter(fontSize: 8, color: AppColors.outline),
              getTitle: (i, angle) {
                const titles = ['Matematika', 'Fizika', 'Kimyo', 'Ingliz', 'Tarix'];
                return RadarChartTitle(text: i < titles.length ? titles[i] : '', angle: angle);
              },
              tickCount: 4,
            )),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Legend(color: AppColors.primaryContainer, label: 'Matematika 92%'),
              const SizedBox(width: 16),
              _Legend(color: AppColors.secondary, label: 'Fizika 78%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final dynamic user;
  const _AchievementsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("So'nggi yutuqlar", style: AppTextStyles.headlineSm),
            GestureDetector(
              onTap: () {},
              child: Text('Hammasi',
                  style: GoogleFonts.inter(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _AchievCard(icon: '🏆', title: 'Bilimdon', sub: '50 darsni yakunladi', color: AppColors.goldColor, unlocked: true),
            _AchievCard(icon: '⚡', title: 'Quick Learner', sub: '5 dars bir kunda', color: AppColors.tertiaryContainer, unlocked: true),
            _AchievCard(icon: '🔥', title: 'Streak Master', sub: '14 kunlik davomiylik', color: AppColors.streakColor, unlocked: true),
            _AchievCard(icon: '👑', title: 'Grandmaster', sub: 'Hali ochilmagan', color: AppColors.outline, unlocked: false),
          ],
        ),
      ],
    );
  }
}

class _AchievCard extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final Color color;
  final bool unlocked;
  const _AchievCard({required this.icon, required this.title, required this.sub, required this.color, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? color.withValues(alpha: 0.07)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? color.withValues(alpha: 0.25)
              : AppColors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Text(unlocked ? icon : '🔒', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: unlocked ? color : AppColors.outline),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 4),
          Text(sub, style: AppTextStyles.labelSm, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text('Ajoyib natija, Alisher!',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
          const SizedBox(height: 10),
          Text(
            'Siz maktabingizda o\'quvchilar orasida TOP 5% ga kirdingiz. Shunday davom eting!',
            style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.90),
                height: 1.5),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              ),
              child: Text("Do'stlar bilan ulashish",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.labelSm),
    ]);
  }
}
