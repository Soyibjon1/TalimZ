import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/logo_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                const SmallLogoWidget(size: 32),
                const SizedBox(width: 12),
                Text(
                  "Ta'limZ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                color: AppColors.onSurface,
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────
                  _ProfileHeader(user: user)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 20),

                  // ── Stats ────────────────────────────────────────────
                  _StatsRow(user: user)
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 350.ms),

                  const SizedBox(height: 14),

                  // ── Streak card ───────────────────────────────────────
                  _SimpleCard(
                    child: Row(children: [
                      _IconBox(icon: Icons.local_fire_department_rounded,
                          color: AppColors.streakColor),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Kunlik faollik', style: AppTextStyles.labelSm),
                        Text('${user.studyDays} kun', style: AppTextStyles.labelLg),
                      ]),
                      const Spacer(),
                      Text('🔥', style: const TextStyle(fontSize: 28)),
                    ]),
                  ).animate(delay: 120.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 14),

                  // ── Teacher panel link ────────────────────────────────
                  GestureDetector(
                    onTap: () => context.push('/teacher'),
                    child: _SimpleCard(
                      color: AppColors.primaryContainer.withValues(alpha: 0.07),
                      border: Border.all(
                          color: AppColors.primaryContainer.withValues(alpha: 0.25)),
                      child: Row(children: [
                        _IconBox(
                            icon: Icons.dashboard_rounded,
                            color: AppColors.primaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("O'qituvchi paneli", style: AppTextStyles.labelMd),
                            Text('Sinf tahlili va AI iqtidor ko\'rsatkichlari',
                                style: AppTextStyles.labelSm),
                          ]),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.primaryContainer),
                      ]),
                    ),
                  ).animate(delay: 150.ms).fadeIn(duration: 350.ms),

                  const SizedBox(height: 14),

                  // ── Badges ───────────────────────────────────────────
                  _BadgesCard(user: user)
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 350.ms),

                  const SizedBox(height: 14),

                  // ── Menu ─────────────────────────────────────────────
                  _MenuSection()
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 350.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: AppColors.surfaceContainerLowest, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.surfaceContainerLowest, width: 2),
              ),
              child: Center(
                child: Text('${user.level}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(user.name, style: AppTextStyles.headlineSm),
        const SizedBox(height: 4),
        Text('${user.title} • ${user.xp} XP',
            style: AppTextStyles.bodySm),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.25)),
          ),
          child: Text('Keyingi darajagacha 580 XP qoldi',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryContainer,
              )),
        ),
      ],
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SimpleCard(
            child: Column(
              children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(height: 8),
                Text('${user.completedTests}', style: AppTextStyles.headlineSm),
                Text('Bajarilgan\ntestlar',
                    style: AppTextStyles.labelSm,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SimpleCard(
            child: Column(
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.goldColor, size: 22),
                const SizedBox(height: 8),
                Text('${user.averageScore.toInt()}%', style: AppTextStyles.headlineSm),
                Text("O'rtacha ball",
                    style: AppTextStyles.labelSm,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SimpleCard(
            child: Column(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.goldColor, size: 22),
                const SizedBox(height: 8),
                Text('${user.level}', style: AppTextStyles.headlineSm),
                Text('Daraja',
                    style: AppTextStyles.labelSm,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Badges Card ──────────────────────────────────────────────────────────
class _BadgesCard extends StatelessWidget {
  final UserModel user;
  const _BadgesCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return _SimpleCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yutuqlarim', style: AppTextStyles.labelLg),
              GestureDetector(
                onTap: () {},
                child: Text('Barchasi',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: user.badges.map((b) => _BadgeItem(badge: b)).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  const _BadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: badge.isUnlocked
                ? AppColors.goldColor.withValues(alpha: 0.10)
                : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: badge.isUnlocked
                  ? AppColors.goldColor.withValues(alpha: 0.35)
                  : AppColors.outlineVariant,
              width: 1.5,
            ),
            boxShadow: badge.isUnlocked
                ? [
                    BoxShadow(
                      color: AppColors.goldColor.withValues(alpha: 0.20),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(badge.isUnlocked ? badge.icon : '🔒',
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 52,
          child: Text(badge.name,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: badge.isUnlocked ? AppColors.onSurface : AppColors.outline,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItemData(
          icon: Icons.book_outlined,
          label: 'Darsliklarim',
          sub: '6 ta faol kurs',
          onTap: () {}),
      _MenuItemData(
          icon: Icons.settings_outlined,
          label: 'Sozlamalar',
          sub: 'Profil va xavfsizlik',
          onTap: () {}),
      _MenuItemData(
          icon: Icons.help_outline_rounded,
          label: 'Yordam markazi',
          sub: 'Savollar va qo\'llab-quvvatlash',
          onTap: () {}),
    ];

    return Column(
      children: [
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: item.onTap,
                child: _SimpleCard(
                  child: Row(children: [
                    _IconBox(icon: item.icon, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: AppTextStyles.labelMd),
                            Text(item.sub, style: AppTextStyles.labelSm),
                          ]),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.outline),
                  ]),
                ),
              ),
            )),

        // Logout
        GestureDetector(
          onTap: () {},
          child: _SimpleCard(
            border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25)),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Chiqish',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.error)),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  _MenuItemData(
      {required this.icon,
      required this.label,
      required this.sub,
      required this.onTap});
}

// ─── Shared helpers ────────────────────────────────────────────────────────
class _SimpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Border? border;

  const _SimpleCard({
    required this.child,
    this.padding,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: AppColors.outlineVariant),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
