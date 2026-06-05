import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TodayTasksSection extends StatelessWidget {
  const TodayTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = MockData.todayTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak banner
        _StreakBanner(),
        const SizedBox(height: 16),
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bugungi vazifalar', style: AppTextStyles.headlineSm),
            GestureDetector(
              onTap: () {},
              child: Text('Hammasi',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  )),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...tasks.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskItem(task: t),
            )),
      ],
    );
  }
}

class _StreakBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, Color(0xFF0040AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('🔥', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text('7 kunlik natija!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ]),
                const SizedBox(height: 5),
                Text(
                  'O\'rganishda davom eting! Bugun 50 XP to\'plash orqali seriyangizni saqlang.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('7',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                Text('KUN',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 0.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskModel task;
  const _TaskItem({required this.task});

  Color get _iconBg {
    switch (task.subject) {
      case 'Kimyo':
        return AppColors.tertiary.withValues(alpha: 0.10);
      case 'Fizika':
        return AppColors.primary.withValues(alpha: 0.10);
      default:
        return AppColors.secondary.withValues(alpha: 0.10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/quiz/${task.subject}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(task.subjectIcon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.labelMd),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.timer_outlined,
                        size: 12, color: AppColors.outline),
                    const SizedBox(width: 3),
                    Text('${task.duration} min',
                        style: AppTextStyles.labelSm),
                    const SizedBox(width: 10),
                    Text('+${task.xpReward} XP',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryContainer,
                        )),
                  ]),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
