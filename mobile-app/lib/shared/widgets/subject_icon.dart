import 'package:flutter/material.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';

class SubjectIcon extends StatelessWidget {
  final SubjectModel subject;
  final double size;
  final bool large;

  const SubjectIcon({
    super.key,
    required this.subject,
    this.size = 44,
    this.large = false,
  });

  Color get _bgColor {
    switch (subject.color) {
      case SubjectColor.blue:
        return AppColors.primary.withValues(alpha: 0.12);
      case SubjectColor.orange:
        return AppColors.tertiary.withValues(alpha: 0.12);
      case SubjectColor.green:
        return AppColors.secondary.withValues(alpha: 0.12);
      case SubjectColor.purple:
        return const Color(0xFF7C3AED).withValues(alpha: 0.12);
      case SubjectColor.teal:
        return const Color(0xFF0891B2).withValues(alpha: 0.12);
      case SubjectColor.yellow:
        return const Color(0xFFD97706).withValues(alpha: 0.12);
    }
  }

  Color get _borderColor {
    switch (subject.color) {
      case SubjectColor.blue:
        return AppColors.primary.withValues(alpha: 0.20);
      case SubjectColor.orange:
        return AppColors.tertiary.withValues(alpha: 0.20);
      case SubjectColor.green:
        return AppColors.secondary.withValues(alpha: 0.20);
      case SubjectColor.purple:
        return const Color(0xFF7C3AED).withValues(alpha: 0.20);
      case SubjectColor.teal:
        return const Color(0xFF0891B2).withValues(alpha: 0.20);
      case SubjectColor.yellow:
        return const Color(0xFFD97706).withValues(alpha: 0.20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(large ? 16 : 12),
        border: Border.all(color: _borderColor),
      ),
      child: Center(
        child: Text(
          subject.icon,
          style: TextStyle(fontSize: large ? 24 : 18),
        ),
      ),
    );
  }
}

class SubjectProgressBar extends StatelessWidget {
  final double progress;
  final SubjectColor color;
  final double height;

  const SubjectProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 6,
  });

  Color get _fillColor {
    switch (color) {
      case SubjectColor.blue:
        return AppColors.primary;
      case SubjectColor.orange:
        return AppColors.tertiaryContainer;
      case SubjectColor.green:
        return AppColors.secondary;
      case SubjectColor.purple:
        return const Color(0xFF7C3AED);
      case SubjectColor.teal:
        return const Color(0xFF0891B2);
      case SubjectColor.yellow:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: AppColors.surfaceContainerHigh,
        valueColor: AlwaysStoppedAnimation<Color>(_fillColor),
      ),
    );
  }
}
