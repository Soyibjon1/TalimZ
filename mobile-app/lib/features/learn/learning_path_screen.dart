import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = MockData.learningPath;

    return Column(
      children: [
        // Level card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _LevelCard()
              .animate()
              .fadeIn(duration: 350.ms),
        ),

        // Path
        Expanded(
          child: Stack(
            children: [
              // Dot grid background
              CustomPaint(
                painter: _DotGridPainter(),
                child: const SizedBox.expand(),
              ),

              // Nodes + connections
              LayoutBuilder(builder: (ctx, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;
                return Stack(
                  children: [
                    // Curved paths between nodes
                    CustomPaint(
                      size: Size(w, h),
                      painter: _PathPainter(nodes: nodes, width: w, height: h),
                    ),
                    // Node widgets
                    ...nodes.asMap().entries.map(
                          (e) => _buildNode(context, e.value, w, h, e.key),
                        ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNode(BuildContext context, LearningPathNode node,
      double w, double h, int idx) {
    final x = node.offsetX * w;
    final y = node.offsetY * h;

    if (node.status == NodeStatus.milestone) {
      return Positioned(
        left: x - 40,
        top: y - 56,
        child: _MilestoneNode(node: node)
            .animate(delay: Duration(milliseconds: 100 + idx * 80))
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1)),
      );
    }

    return Positioned(
      left: x - 32,
      top: y - 68,
      child: _PathNode(node: node)
          .animate(delay: Duration(milliseconds: 80 + idx * 70))
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1)),
    );
  }
}

// ─── Level Card ─────────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Level 12', style: AppTextStyles.headlineSm),
                Text('Mathematics Track', style: AppTextStyles.bodySm),
              ]),
              Text('Next: 350 XP',
                  style: AppTextStyles.labelSm),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 0.65),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('65% Progress',
                style: AppTextStyles.labelSm
                    .copyWith(color: AppColors.primaryContainer)),
            Text('Level 13', style: AppTextStyles.labelSm),
          ]),
        ],
      ),
    );
  }
}

// ─── Path Node ───────────────────────────────────────────────────────────────
class _PathNode extends StatelessWidget {
  final LearningPathNode node;
  const _PathNode({required this.node});

  Color get _bg {
    switch (node.status) {
      case NodeStatus.completed:
        return AppColors.secondary;
      case NodeStatus.current:
        return AppColors.primaryContainer;
      case NodeStatus.locked:
        return AppColors.surfaceContainerHigh;
      case NodeStatus.milestone:
        return AppColors.goldColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = node.status == NodeStatus.locked;
    final isCurrent = node.status == NodeStatus.current;
    final isCompleted = node.status == NodeStatus.completed;

    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent
                    ? AppColors.primaryContainer.withValues(alpha: 0.35)
                    : Colors.transparent,
                width: 4,
              ),
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: _bg.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock_rounded,
                      color: Colors.white60, size: 22)
                  : isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 24)
                      : const Icon(Icons.school_rounded,
                          color: Colors.white, size: 24),
            ),
          ),

          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('JORIY',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  )),
            )
          else
            const SizedBox(height: 4),

          const SizedBox(height: 3),
          Text(
            node.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isLocked ? AppColors.outline : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestone Node ──────────────────────────────────────────────────────────
class _MilestoneNode extends StatelessWidget {
  final LearningPathNode node;
  const _MilestoneNode({required this.node});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: AppColors.cardShadow,
            ),
            child: const Center(
              child: Text('🚀', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 5),
          Text(node.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiaryContainer)),
          Text('${node.xpMilestone} XP',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.tertiaryContainer)),
        ],
      ),
    );
  }
}

// ─── Path Painter ─────────────────────────────────────────────────────────────
class _PathPainter extends CustomPainter {
  final List<LearningPathNode> nodes;
  final double width;
  final double height;
  const _PathPainter(
      {required this.nodes, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final completedPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lockedPaint = Paint()
      ..color = AppColors.outline.withValues(alpha: 0.28)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < nodes.length - 1; i++) {
      final a = nodes[i];
      final b = nodes[i + 1];
      final p1 = Offset(a.offsetX * width, a.offsetY * height);
      final p2 = Offset(b.offsetX * width, b.offsetY * height);

      final active = a.status == NodeStatus.completed ||
          a.status == NodeStatus.current;

      final path = Path()..moveTo(p1.dx, p1.dy);
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      final cp1 = Offset(p1.dx, mid.dy);
      final cp2 = Offset(p2.dx, mid.dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);

      canvas.drawPath(path, active ? completedPaint : lockedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Dot Grid ─────────────────────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.outline.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
