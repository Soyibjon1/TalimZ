import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _features = [
    _Feature(
      icon: '🤖',
      title: 'AI asosida ta\'lim',
      desc: 'Shaxsiy AI murabbiy o\'qish uslubingizni tahlil qilib, '
          'mukammal darslarni yaratadi.',
    ),
    _Feature(
      icon: '📊',
      title: 'Interaktiv darslar',
      desc: 'Video darslar, testlar va AI suhbat — barchasi bir platformada '
          'o\'zbekchada.',
    ),
    _Feature(
      icon: '🏆',
      title: 'Natijalar tahlili',
      desc: 'Har bir test AI tomonidan tahlil qilinadi, iqtidoringiz '
          'aniqlanadi va o\'qituvchiga yetkaziladi.',
    ),
    _Feature(
      icon: '💎',
      title: 'Iqtidor kashfiyoti',
      desc: 'Yashirin salohiyatingizni oching. Olimpiadadagi g\'alaba '
          'siz kutmoqda.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.onSurface,
              onPressed: () => context.go('/home'),
            ),
            title: Text('TalimZ',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer)),
            actions: [
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text("Kirish",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryContainer,
                    )),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Hero ───────────────────────────────────────────
                  _HeroSection()
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: 0.08, end: 0),

                  const SizedBox(height: 28),

                  // ── Features ───────────────────────────────────────
                  Text('Nega aynan TalimZ?',
                      style: AppTextStyles.headlineSm)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 350.ms),
                  const SizedBox(height: 6),
                  Text(
                    "Minglab o'quvchilar olimpiadaga tayyorlanish uchun TalimZ ni tanlashdi.",
                    style: AppTextStyles.bodySm,
                  ).animate(delay: 250.ms).fadeIn(duration: 350.ms),
                  const SizedBox(height: 16),

                  ..._features.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _FeatureCard(f: e.value)
                              .animate(
                                  delay: Duration(
                                      milliseconds: 300 + e.key * 80))
                              .fadeIn(duration: 350.ms)
                              .slideX(begin: 0.05, end: 0),
                        ),
                      ),

                  const SizedBox(height: 20),

                  // ── Stats ──────────────────────────────────────────
                  _StatsRow()
                      .animate(delay: 650.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 24),

                  // ── Final CTA ──────────────────────────────────────
                  _CtaBanner()
                      .animate(delay: 750.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  Text(
                    '© 2024 TalimZ. O\'zbekiston bo\'ylab ta\'limni taraqqiy ettiramiz.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelSm
                        .copyWith(color: AppColors.outline),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero ──────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text("O'zbekiston #1 AI ta'lim platformasi",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Headline
        Text(
          "Kelajak ta'limiga\nkush bellvisiz",
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLgMobile,
        ),
        const SizedBox(height: 12),
        Text(
          "TalimZ ta'lim olishni osonlashtiradi. Har bir o'quvchining "
          "salohiyatini ochib, maqsadlariga yetishishga yordam beradi.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              shadowColor:
                  AppColors.primaryContainer.withValues(alpha: 0.40),
            ),
            child: Text('Bepul boshlash',
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => context.go('/home'),
          child: Text("Demo ko'rish",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              )),
        ),
        const SizedBox(height: 22),

        // Hero illustration
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryContainer.withValues(alpha: 0.10),
                AppColors.secondary.withValues(alpha: 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Stack(
            children: [
              Center(
                child: Text('📚', style: const TextStyle(fontSize: 72)),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text("2 000+ foydalanuvchi",
                          style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Feature Card ──────────────────────────────────────────────────────────
class _FeatureCard extends StatelessWidget {
  final _Feature f;
  const _FeatureCard({required this.f});

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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Center(child: Text(f.icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.title, style: AppTextStyles.labelLg),
                const SizedBox(height: 3),
                Text(f.desc, style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ──────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: '2 000+', label: "Foydalanuvchi"),
        const SizedBox(width: 8),
        _StatBox(value: '5 Fan', label: 'Mavjud'),
        const SizedBox(width: 8),
        _StatBox(value: '98%', label: 'Qoniqish'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer)),
            const SizedBox(height: 3),
            Text(label, style: AppTextStyles.labelSm),
          ],
        ),
      ),
    );
  }
}

// ─── CTA Banner ─────────────────────────────────────────────────────────────
class _CtaBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryContainer, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("O'z bilimingizni oshiring!",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            "Hozir ro'yxatdan o'ting va AI kuchli ta'lim platformasidan bepul foydalaning.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.5),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Bepul boshlash',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryContainer)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final String icon;
  final String title;
  final String desc;
  const _Feature({required this.icon, required this.title, required this.desc});
}
