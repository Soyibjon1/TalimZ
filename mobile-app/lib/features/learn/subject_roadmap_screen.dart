import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/data/mock_data.dart';
import '../../core/models/models.dart';

class SubjectRoadmapScreen extends StatefulWidget {
  final String subjectId;
  const SubjectRoadmapScreen({super.key, required this.subjectId});

  @override
  State<SubjectRoadmapScreen> createState() => _SubjectRoadmapScreenState();
}

class _SubjectRoadmapScreenState extends State<SubjectRoadmapScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roadmap = MockData.subjectRoadmaps[widget.subjectId];
    
    if (roadmap == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Ma\'lumot topilmadi')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage('assets/images/avatar.png'),
              onBackgroundImageError: (exception, stackTrace) {},
              child: const Text('T'),
            ),
            const SizedBox(width: 12),
            Text(
              'TalimZ',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flash_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '1,240 XP',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildProgressCard(roadmap),
              const SizedBox(height: 40),
              buildRoadmapPath(roadmap.topics),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgressCard(SubjectRoadmapModel roadmap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Umumiy progress',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(roadmap.progress * 100).round()}%',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${roadmap.earnedXP} / ${roadmap.totalXP} XP',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget buildRoadmapPath(List<RoadmapTopicModel> topics) {
    return SizedBox(
      height: topics.length * 140.0,
      child: Stack(
        children: [
          // Background path line
          buildPathLine(topics.length),
          // Nodes
          ...topics.asMap().entries.map((entry) {
            final index = entry.key;
            final topic = entry.value;
            final isRight = index % 2 == 1;
            
            return Positioned(
              top: index * 140.0,
              left: isRight ? MediaQuery.of(context).size.width * 0.5 : 0,
              right: isRight ? 0 : MediaQuery.of(context).size.width * 0.5,
              child: buildNode(topic, index).animate(delay: (index * 200).ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: isRight ? 0.5 : -0.5, end: 0),
            );
          }),
        ],
      ),
    );
  }

  Widget buildPathLine(int nodeCount) {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.5 - 2,
      top: 60,
      child: SizedBox(
        width: 4,
        height: (nodeCount - 1) * 140.0,
        child: CustomPaint(
          painter: ZigzagPathPainter(),
        ),
      ),
    );
  }

  Widget buildNode(RoadmapTopicModel topic, int index) {
    final isCompleted = topic.status == RoadmapTopicStatus.completed;
    final isCurrent = topic.status == RoadmapTopicStatus.current;
    final isBonus = topic.status == RoadmapTopicStatus.bonus;
    final isLocked = topic.status == RoadmapTopicStatus.locked;

    if (isBonus) {
      return buildBonusNode(topic);
    }

    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          // Haptic feedback
          // HapticFeedback.lightImpact();
          
          // Navigate to lessons
          context.push('/subject/${widget.subjectId}/topic/${topic.id}');
          
          // Show snackbar with topic info
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${topic.title} ochildi!'),
              backgroundColor: isCompleted 
                ? const Color(0xFF10B981) 
                : const Color(0xFF3B82F6),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // JORIY tag for current topic
          if (isCurrent) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'JORIY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Main node circle with animation
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = isCurrent 
                ? 1.0 + (_pulseController.value * 0.1)
                : 1.0;
              
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: isCompleted ? 80 : isCurrent ? 90 : 70,
                  height: isCompleted ? 80 : isCurrent ? 90 : 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                      ? const Color(0xFF10B981)
                      : isCurrent 
                        ? const Color(0xFF3B82F6)
                        : Colors.grey[300],
                    boxShadow: isLocked ? null : [
                      BoxShadow(
                        color: (isCompleted 
                          ? const Color(0xFF10B981)
                          : isCurrent 
                            ? const Color(0xFF3B82F6)
                            : Colors.grey).withValues(alpha: 0.4),
                        blurRadius: isCurrent ? 16 : 12,
                        spreadRadius: isCurrent ? 4 : 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLocked
                      ? Icon(Icons.lock, color: Colors.grey[600], size: 28)
                      : isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 32)
                        : Icon(Icons.school, color: Colors.white, size: 28),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Topic name with enhanced styling
          Container(
            constraints: const BoxConstraints(maxWidth: 140),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrent 
                  ? const Color(0xFF3B82F6)
                  : isCompleted 
                    ? const Color(0xFF10B981)
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              topic.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Progress indicator for current topic
          if (isCurrent && topic.completedLessons > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${topic.completedLessons}/${topic.lessonCount} dars',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBonusNode(RoadmapTopicModel topic) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🚀', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '${topic.xpReward} XP',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bonus',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    ).animate(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }
}

class ZigzagPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dashPaint = Paint()
      ..color = const Color(0xFF3B82F6).withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 0);
    
    // Create curved zigzag path
    final segments = (size.height / 140).floor();
    for (int i = 0; i < segments; i++) {
      final startY = i * 140.0;
      final endY = (i + 1) * 140.0;
      final midY = startY + 70;
      
      // Create smooth curve
      path.quadraticBezierTo(
        0, midY - 20,
        0, midY,
      );
      path.quadraticBezierTo(
        0, midY + 20,
        0, endY,
      );
    }
    
    // Draw dashed line effect
    drawDashedPath(canvas, path, dashPaint);
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}