import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RecommendCard(
          tag: "O'rtacha",
          tagIcon: Icons.trending_up_rounded,
          tagColor: AppColors.tertiaryContainer,
          title: 'Matematika: Sinuslar',
          subtitle: 'Trigonometriya asoslarini mustahkamlang.',
          xpLabel: '+150 XP',
          onTap: () => context.push('/lesson/1'),
        ),
        const SizedBox(height: 12),
        _RecommendCard(
          tag: 'Oson',
          tagIcon: Icons.check_circle_outline_rounded,
          tagColor: AppColors.secondary,
          title: 'Ingliz tili: Grammatika',
          subtitle: 'Present Simple darsini yakunlang.',
          xpLabel: '+100 XP',
          onTap: () => context.push('/lesson/2'),
        ),
      ],
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final String tag;
  final IconData tagIcon;
  final Color tagColor;
  final String title;
  final String subtitle;
  final String xpLabel;
  final VoidCallback onTap;

  const _RecommendCard({
    required this.tag,
    required this.tagIcon,
    required this.tagColor,
    required this.title,
    required this.subtitle,
    required this.xpLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tagColor.withValues(alpha: 0.25),
                          tagColor.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.school_rounded,
                          color: tagColor.withValues(alpha: 0.35), size: 44),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tagIcon, size: 10, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(tag,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.labelLg),
                        const SizedBox(height: 3),
                        Text(subtitle, style: AppTextStyles.bodySm),
                        const SizedBox(height: 6),
                        Text(xpLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
