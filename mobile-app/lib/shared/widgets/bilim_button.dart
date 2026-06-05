import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class BilimButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isOutlined;
  final bool isSmall;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;

  const BilimButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isSmall = false,
    this.backgroundColor,
    this.textColor,
    this.width,
  });

  @override
  State<BilimButton> createState() => _BilimButtonState();
}

class _BilimButtonState extends State<BilimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final bgColor =
        widget.backgroundColor ?? AppColors.primaryContainer;
    final fgColor = widget.textColor ?? AppColors.onPrimary;
    final height = widget.isSmall ? 40.0 : 52.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.width,
          height: height,
          decoration: BoxDecoration(
            color: widget.isOutlined ? Colors.transparent : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: widget.isOutlined
                ? Border.all(color: AppColors.outlineVariant)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize:
                widget.width == null ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: widget.isSmall ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    color: widget.isOutlined
                        ? AppColors.primary
                        : fgColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
