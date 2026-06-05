import 'package:flutter/material.dart';

class AppColors {
  // Primary - Ta'limZ brand colors
  static const Color primary = Color(0xFF1565C0); // Ta'limZ ko'k rangi
  static const Color primaryContainer = Color(0xFF42A5F5); // Ochiq ko'k
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF8F7FF);
  static const Color inversePrimary = Color(0xFFB3C5FF);
  
  // Ta'limZ brand gradient colors
  static const Color brandBlue1 = Color(0xFF1565C0); // To'q ko'k
  static const Color brandBlue2 = Color(0xFF42A5F5); // O'rta ko'k  
  static const Color brandBlue3 = Color(0xFF90CAF9); // Ochiq ko'k
  
  // Accent color (for AI features)
  static const Color accent = Color(0xFF5CFD80);

  // Secondary (Green)
  static const Color secondary = Color(0xFF006E2A);
  static const Color secondaryContainer = Color(0xFF5CFD80);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF00732C);

  // Tertiary (Orange)
  static const Color tertiary = Color(0xFF983E00);
  static const Color tertiaryContainer = Color(0xFFBF5000);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFF7F4);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Surface
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF424656);
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);

  // Outline
  static const Color outline = Color(0xFF727687);
  static const Color outlineVariant = Color(0xFFC2C6D8);
  static const Color surfaceTint = Color(0xFF0054D6);

  // Dark mode surfaces
  static const Color darkSurface = Color(0xFF1E2937);
  static const Color darkSurfaceCard = Color(0xFF253141);
  static const Color darkSurfaceElevated = Color(0xFF2D3B4E);

  // Gamification
  static const Color xpColor = Color(0xFF0066FF);
  static const Color streakColor = Color(0xFFFF6B35);
  static const Color goldColor = Color(0xFFFFAB00);

  // Card shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> modalShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 12),
    ),
  ];
}
