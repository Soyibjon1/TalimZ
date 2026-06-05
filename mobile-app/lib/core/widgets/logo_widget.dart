import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showText;
  final Color? textColor;
  
  const LogoWidget({
    super.key,
    this.width,
    this.height,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo ikonu
        SizedBox(
          width: width ?? 120,
          height: height ?? 120,
          child: _buildLogoIcon(),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            "Ta'limZ",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).primaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoIcon() {
    // Haqiqiy Ta'limZ logosini ishlatamiz
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Agar logo yuklanmasa, fallback ko'rsatish
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    // Fallback logo (agar haqiqiy logo yuklanmasa)
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo elementi
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikki odam figurasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Birinchi odam
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ikkinchi odam
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Ta'lim belgisi
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Kichik logo versiyasi
class SmallLogoWidget extends StatelessWidget {
  final double size;
  final Color? color;

  const SmallLogoWidget({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: (color ?? Colors.blue).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color ?? const Color(0xFF1565C0),
                    (color ?? const Color(0xFF42A5F5)).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
              child: Icon(
                Icons.school,
                color: Colors.white,
                size: size * 0.6,
              ),
            );
          },
        ),
      ),
    );
  }
}