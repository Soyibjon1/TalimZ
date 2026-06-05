import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockData.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Bildirishnomalar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            )),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Barchasini o\'qish',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ],
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, state) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _NotifItem(item: items[i])
            .animate(delay: (i * 80).ms)
            .fadeIn(duration: 350.ms)
            .slideX(begin: 0.05, end: 0),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final AppNotification item;
  const _NotifItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead
            ? AppColors.surfaceContainerLowest
            : AppColors.primaryContainer.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead
              ? AppColors.outlineVariant
              : AppColors.primaryContainer.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.labelMd),
                const SizedBox(height: 3),
                Text(item.body, style: AppTextStyles.bodySm),
                const SizedBox(height: 5),
                Text(
                  _formatTime(item.time),
                  style: AppTextStyles.labelSm.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
          if (!item.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }
}
