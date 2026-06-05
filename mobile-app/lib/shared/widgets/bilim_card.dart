import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BilimCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hoverable;
  final VoidCallback? onTap;
  final Border? border;

  const BilimCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16,
    this.hoverable = false,
    this.onTap,
    this.border,
  });

  @override
  State<BilimCard> createState() => _BilimCardState();
}

class _BilimCardState extends State<BilimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ??
                Border.all(color: AppColors.outlineVariant, width: 1),
            boxShadow: AppColors.cardShadow,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
