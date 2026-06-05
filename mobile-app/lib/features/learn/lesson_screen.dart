import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _playing = false;
  final double _progress = 0.52;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tab.dispose();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Video player ─────────────────────────────────────────────
          _VideoSection(
            playing: _playing,
            progress: _progress,
            onPlayTap: () => setState(() => _playing = !_playing),
            onBack: () => context.pop(),
          ),

          // ── Progress & nav ────────────────────────────────────────────
          _LessonHeader(progress: _progress),

          // ── Tabs ──────────────────────────────────────────────────────
          _LessonTabBar(tab: _tab),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _NotesTab(),
                _ResourcesTab(),
                _TestTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Video Section ─────────────────────────────────────────────────────────
class _VideoSection extends StatelessWidget {
  final bool playing;
  final double progress;
  final VoidCallback onPlayTap;
  final VoidCallback onBack;

  const _VideoSection({
    required this.playing,
    required this.progress,
    required this.onPlayTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060D1F),
      child: Column(
        children: [
          // Status bar
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 6,
              left: 4,
              right: 14,
              bottom: 6,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 22),
                ),
                Expanded(
                  child: Text(
                    'Matematika: Trigonometriya asoslari',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.tertiaryContainer.withValues(
                            alpha: 0.45)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text('+15 XP',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[300],
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Video viewport
          GestureDetector(
            onTap: onPlayTap,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // BG gradient + sine wave
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF060D1F), Color(0xFF0D2147)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CustomPaint(
                    painter: _SineWavePainter(),
                    child: const SizedBox.expand(),
                  ),

                  // Play button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: playing
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.40),
                          width: 2),
                    ),
                    child: Icon(
                      playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  // Duration bottom left
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Text('12:45 / 24:00',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.80),
                        )),
                  ),

                  // Controls bottom right
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Row(children: [
                      Icon(Icons.settings_outlined,
                          color: Colors.white.withValues(alpha: 0.80),
                          size: 17),
                      const SizedBox(width: 10),
                      Icon(Icons.fullscreen_rounded,
                          color: Colors.white.withValues(alpha: 0.80),
                          size: 20),
                    ]),
                  ),

                  // Progress bar overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lesson Header ──────────────────────────────────────────────────────────
class _LessonHeader extends StatelessWidget {
  final double progress;
  const _LessonHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              _StatusBadge(
                label: '${(progress * 100).toInt()}% Tugallandi',
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _StatusBadge(label: '15 XP Qoldi', color: AppColors.tertiary),
            ],
          ),
          const SizedBox(height: 8),
          Text('3-Mavzu: Sinus va Kosinus funksiyalari',
              style: AppTextStyles.bodySm),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_rounded, size: 15),
                label: const Text('Oldingi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Keyingi',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              )),
        ],
      ),
    );
  }
}

// ─── Tab Bar ────────────────────────────────────────────────────────────────
class _LessonTabBar extends StatelessWidget {
  final TabController tab;
  const _LessonTabBar({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: TabBar(
        controller: tab,
        tabs: const [
          Tab(text: 'Dars yozuvlari'),
          Tab(text: 'Resurslar'),
          Tab(text: 'Test'),
        ],
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.outline,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}

// ─── Notes Tab ──────────────────────────────────────────────────────────────
class _NotesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trigonometriya Asoslari: Sinus',
              style: AppTextStyles.labelLg),
          const SizedBox(height: 12),
          Text(
            "Sinus (sin) – to'g'ri burchakli uchburchakda berilgan (α) o'tkir burchak "
            "qarshisidagi katetning gipotenuza bilan nisbatidir.",
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 14),

          // Formula block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.20)),
            ),
            child: Text(
              'sin(α) = Qarshisidagi katet / Gipotenuza',
              style: GoogleFonts.spaceMono(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: 14),
          Text(
            "Birlik aylanada sinus burchak radius-vektorining ordinatasiga (y) tengdir. "
            "Sinus funksiyasi davriy bo'lib, uning asosiy davri 2π ga teng.",
            style: AppTextStyles.bodyMd,
          ),

          const SizedBox(height: 18),

          // AI Mentor card
          _AiMentorCard()
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: 18),

          Text("Darslar ro'yxati", style: AppTextStyles.labelLg),
          const SizedBox(height: 10),
          _LessonListItem(
              n: 1,
              title: 'Trigonometriya asoslari',
              sub: 'Hozir ko\'rilmoqda',
              current: true),
          _LessonListItem(
              n: 2, title: 'Sinuslar teoremasi', sub: '15:20 min'),
          _LessonListItem(
              n: 3, title: 'Kosinuslar teoremasi', sub: '18:45 min'),
        ],
      ),
    );
  }
}

class _AiMentorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('TalimZ Mentor',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ]),
          const SizedBox(height: 10),
          Text(
            '"Sinus va kosinusni chalkashtirib yubormaslik uchun ularni aylana ustidagi '
            'koordinatalar deb tasavvur qiling — sin(α) = y va cos(α) = x."',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.55,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/ai'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Savol berish',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 13),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonListItem extends StatelessWidget {
  final int n;
  final String title;
  final String sub;
  final bool current;
  const _LessonListItem(
      {required this.n,
      required this.title,
      required this.sub,
      this.current = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: current
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: current
              ? AppColors.primary.withValues(alpha: 0.30)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: current
                  ? AppColors.primary
                  : AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              current ? Icons.play_arrow_rounded : Icons.circle_outlined,
              size: 16,
              color: current ? Colors.white : AppColors.outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$n. $title', style: AppTextStyles.labelMd),
                Text(sub, style: AppTextStyles.labelSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Resources Tab ──────────────────────────────────────────────────────────
class _ResourcesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _ResourceItem(
          icon: Icons.picture_as_pdf_rounded,
          title: 'Trigonometriya formulalar jadvali',
          sub: 'PDF · 2.4 MB',
          color: AppColors.tertiary,
        ).animate(delay: 50.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        _ResourceItem(
          icon: Icons.link_rounded,
          title: 'Interaktiv trigonometriya simulyatori',
          sub: 'Web havolasi',
          color: AppColors.primaryContainer,
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: 10),
        _ResourceItem(
          icon: Icons.quiz_rounded,
          title: 'Mashq topshiriqlari',
          sub: '25 ta savol · PDF',
          color: AppColors.secondary,
        ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
      ],
    );
  }
}

class _ResourceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  const _ResourceItem(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelMd),
                Text(sub, style: AppTextStyles.labelSm),
              ],
            ),
          ),
          Icon(Icons.download_rounded,
              color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

// ─── Test Tab ───────────────────────────────────────────────────────────────
class _TestTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                const Text('📝', style: TextStyle(fontSize: 44)),
                const SizedBox(height: 14),
                Text('Bilimingizni sinab ko\'ring',
                    style: AppTextStyles.headlineSm),
                const SizedBox(height: 8),
                Text('10 ta savol · ~5 daqiqa · +500 XP',
                    style: AppTextStyles.bodySm,
                    textAlign: TextAlign.center),
                const SizedBox(height: 18),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TestStat(icon: '✅', label: "To'g'ri", value: '7'),
                    _TestStat(icon: '❌', label: 'Xato', value: '3'),
                    _TestStat(icon: '⏱️', label: 'Vaqt', value: '2:30'),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => context.push('/quiz/Matematika'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Testni boshlash'),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1, 1)),
        ],
      ),
    );
  }
}

class _TestStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _TestStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.labelSm),
      ],
    );
  }
}

// ─── Sine Wave Painter ─────────────────────────────────────────────────────
class _SineWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _draw(canvas, size, Colors.white.withValues(alpha: 0.12), 0.0, 38.0);
    _draw(canvas, size, Colors.orange.withValues(alpha: 0.18), 60.0, 28.0);
  }

  void _draw(Canvas canvas, Size size, Color color, double phase,
      double amplitude) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const pi = 3.14159265;
    for (double x = 0; x <= size.width; x++) {
      final angle = (x / size.width) * 4 * pi + phase;
      final y = size.height / 2 + amplitude * _sin(angle);
      x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  double _sin(double x) {
    x = x % (2 * 3.14159265);
    if (x < 0) x += 2 * 3.14159265;
    // Taylor series approx
    final x2 = x * x;
    return x * (1 - x2 / 6 * (1 - x2 / 20 * (1 - x2 / 42)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
