import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final analysis = result.talentAnalysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _ScoreHero(result: result)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.88, 0.88), end: const Offset(1, 1)),
                const SizedBox(height: 20),
                _AiAnalysisBanner(analysis: analysis)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 16),
                _SkillScoresCard(analysis: analysis)
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ListCard(
                        title: 'Kuchli tomonlar',
                        icon: '💪',
                        items: analysis.strengths,
                        color: AppColors.secondary,
                      ).animate(delay: 380.ms).fadeIn(duration: 350.ms),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ListCard(
                        title: 'Yaxshilash',
                        icon: '📈',
                        items: analysis.improvements,
                        color: AppColors.tertiary,
                      ).animate(delay: 420.ms).fadeIn(duration: 350.ms),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _RecommendationsCard(analysis: analysis)
                    .animate(delay: 480.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                _QuestionReviewCard(result: result)
                    .animate(delay: 540.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 20),
                _ActionButtons()
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Score Hero ───────────────────────────────────────────────────────────
class _ScoreHero extends StatelessWidget {
  final QuizResult result;
  const _ScoreHero({required this.result});

  Color get _scoreColor {
    final p = result.percentage;
    if (p >= 80) return AppColors.secondary;
    if (p >= 60) return AppColors.tertiaryContainer;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _scoreColor.withValues(alpha: 0.12),
            _scoreColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _scoreColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(result.talentAnalysis.level.icon,
              style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          Text(
            '${result.percentage.toInt()}%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: _scoreColor,
            ),
          ),
          Text(
            result.talentAnalysis.level.label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _scoreColor,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatPill(
                label: '${result.correctAnswers}/${result.totalQuestions}',
                sub: "To'g'ri",
                color: AppColors.secondary,
              ),
              _StatPill(
                label: '+${result.xpEarned} XP',
                sub: 'Topildi',
                color: AppColors.primaryContainer,
              ),
              _StatPill(
                label: '${result.timeSpentSeconds}s',
                sub: 'Vaqt',
                color: AppColors.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String sub;
  final Color color;
  const _StatPill({required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(sub,
              style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─── AI Analysis Banner ────────────────────────────────────────────────────
class _AiAnalysisBanner extends StatelessWidget {
  final TalentAnalysis analysis;
  const _AiAnalysisBanner({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.smart_toy_rounded,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text('AI Tahlil',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${analysis.aptitudeType} tipi',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(analysis.summary,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.6,
              )),
        ],
      ),
    );
  }
}

// ─── Skill Scores ─────────────────────────────────────────────────────────
class _SkillScoresCard extends StatelessWidget {
  final TalentAnalysis analysis;
  const _SkillScoresCard({required this.analysis});

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
          Text("Ko'nikma tahlili", style: AppTextStyles.labelLg),
          const SizedBox(height: 14),
          ...analysis.skillScores.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SkillBar(label: e.key, value: e.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBar extends StatelessWidget {
  final String label;
  final double value;
  const _SkillBar({required this.label, required this.value});

  Color get _color {
    if (value >= 0.75) return AppColors.secondary;
    if (value >= 0.50) return AppColors.tertiaryContainer;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: AppTextStyles.labelMd),
          Text('${(value * 100).toInt()}%',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _color)),
        ]),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: value),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, v, child) => ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── List Card ────────────────────────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final String title;
  final String icon;
  final List<String> items;
  final Color color;
  const _ListCard({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Expanded(
                child: Text(title,
                    style: AppTextStyles.labelMd,
                    overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text('—', style: AppTextStyles.bodySm)
          else
            ...items.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 7, right: 7),
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      Expanded(child: Text(s, style: AppTextStyles.bodySm)),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

// ─── Recommendations ──────────────────────────────────────────────────────
class _RecommendationsCard extends StatelessWidget {
  final TalentAnalysis analysis;
  const _RecommendationsCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.secondary.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎯', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('AI Tavsiyalar', style: AppTextStyles.labelLg),
          ]),
          const SizedBox(height: 12),
          ...analysis.recommendations.asMap().entries.map(
                (e) => Padding(
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
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Question Review ──────────────────────────────────────────────────────
class _QuestionReviewCard extends StatelessWidget {
  final QuizResult result;
  const _QuestionReviewCard({required this.result});

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
          Text('Savol tahlili', style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.questionResults.asMap().entries.map((e) {
              final ok = e.value.isCorrect;
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ok
                      ? AppColors.secondary.withValues(alpha: 0.10)
                      : AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ok
                        ? AppColors.secondary.withValues(alpha: 0.40)
                        : AppColors.error.withValues(alpha: 0.40),
                  ),
                ),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            ok ? AppColors.secondary : AppColors.error,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _Legend(
                color: AppColors.secondary,
                label: "To'g'ri (${result.correctAnswers})"),
            const SizedBox(width: 16),
            _Legend(
                color: AppColors.error,
                label:
                    'Xato (${result.totalQuestions - result.correctAnswers})'),
          ]),
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
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.labelSm),
    ]);
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Bosh sahifaga',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Qaytadan yechish',
                style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
