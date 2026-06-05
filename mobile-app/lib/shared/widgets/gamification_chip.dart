import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

enum ChipType { xp, streak, level, subject, badge }

class GamificationChip extends StatelessWidget {
  final String label;
  final ChipType type;
  final String? icon;
  final Color? customColor;

  const GamificationChip({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.customColor,
  });

  Color get _bgColor {
    if (customColor != null) return customColor!.withValues(alpha: 0.12);
    switch (type) {
      case ChipType.xp:
        return AppColors.primary.withValues(alpha: 0.10);
      case ChipType.streak:
        return AppColors.streakColor.withValues(alpha: 0.10);
      case ChipType.level:
        return AppColors.secondary.withValues(alpha: 0.10);
      case ChipType.subject:
        return AppColors.primaryContainer.withValues(alpha: 0.10);
      case ChipType.badge:
        return AppColors.goldColor.withValues(alpha: 0.10);
    }
  }

  Color get _textColor {
    if (customColor != null) return customColor!;
    switch (type) {
      case ChipType.xp:
        return AppColors.primary;
      case ChipType.streak:
        return AppColors.streakColor;
      case ChipType.level:
        return AppColors.secondary;
      case ChipType.subject:
        return AppColors.primaryContainer;
      case ChipType.badge:
        return AppColors.goldColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
