import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  int _locationToIndex(String loc) {
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/learn')) return 1;
    if (loc.startsWith('/ai')) return 2;
    if (loc.startsWith('/progress')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final current = _locationToIndex(loc);

    return Scaffold(
      body: child,
      bottomNavigationBar: _BilimNavBar(
        currentIndex: current,
        onTap: (i) {
          const routes = ['/home', '/learn', '/ai', '/progress', '/profile'];
          context.go(routes[i]);
        },
      ),
    );
  }
}

class _BilimNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BilimNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.school_rounded, label: 'Learn'),
    _NavItem(icon: Icons.smart_toy_rounded, label: 'AI'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: const Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final selected = currentIndex == i;
              final isAi = i == 2;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: isAi
                      ? _AiTab(selected: selected)
                      : _RegularTab(
                          item: item, selected: selected),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _RegularTab extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  const _RegularTab({required this.item, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 24,
            color: selected ? AppColors.primaryContainer : AppColors.outline,
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color:
                  selected ? AppColors.primaryContainer : AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiTab extends StatelessWidget {
  final bool selected;
  const _AiTab({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF00C853), Color(0xFF004D20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected ? null : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00C853).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.smart_toy_rounded,
            size: 19,
            color: selected ? Colors.white : AppColors.outline,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'AI',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? const Color(0xFF00C853) : AppColors.outline,
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
