import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

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
      child: Row(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 0.70,
                    strokeWidth: 7,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                  ),
                ),
                Center(
                  child: Text('70%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bugungi maqsad', style: AppTextStyles.labelLg),
                const SizedBox(height: 4),
                Text('3 ta darsdan 2 tasi yakunlandi. Yana bir qadam!',
                    style: AppTextStyles.bodySm),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _MiniStat(icon: '✅', label: '2 dars'),
                    const SizedBox(width: 12),
                    _MiniStat(icon: '⏱️', label: '45 min'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
