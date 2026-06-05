import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../theme/app_colors.dart';

class AppIconGenerator {
  /// Ta'limZ ilovasi uchun app icon yaratadi
  static Future<ui.Image> generateAppIcon(double size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;
    
    // Orqa fon gradient
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(size, size),
      [
        AppColors.brandBlue1,
        AppColors.brandBlue2,
        AppColors.brandBlue3,
      ],
      [0.0, 0.6, 1.0],
    );
    
    paint.shader = gradient;
    
    // Orqa fon (kvadrat rounded corners bilan)
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size),
      Radius.circular(size * 0.22), // 22% rounded corners
    );
    canvas.drawRRect(backgroundRect, paint);
    
    // Logoning asosiy elementi - ikki odam va ta'lim belgisi
    _drawLogoElements(canvas, size);
    
    final picture = recorder.endRecording();
    return await picture.toImage(size.toInt(), size.toInt());
  }
  
  static void _drawLogoElements(Canvas canvas, double size) {
    final paint = Paint()..isAntiAlias = true;
    final center = Offset(size / 2, size / 2);
    
    // Ikki odam figurasi (tepa qismida)
    final personSize = size * 0.08;
    final personY = size * 0.35;
    
    // Birinchi odam (chap)
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(center.dx - personSize * 1.2, personY),
      personSize,
      paint,
    );
    
    // Ikkinchi odam (o'ng)
    paint.color = Colors.white.withValues(alpha: 0.95);
    canvas.drawCircle(
      Offset(center.dx + personSize * 1.2, personY),
      personSize,
      paint,
    );
    
    // Ta'lim belgisi (tanalar) - pastda
    final bodyWidth = size * 0.25;
    final bodyHeight = size * 0.15;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, personY + personSize * 3),
        width: bodyWidth,
        height: bodyHeight,
      ),
      Radius.circular(bodyHeight / 2),
    );
    
    paint.color = Colors.white;
    canvas.drawRRect(bodyRect, paint);
    
    // Kitob yoki dars belgisi (o'rtada)
    final bookSize = size * 0.12;
    final bookRect = Rect.fromCenter(
      center: center,
      width: bookSize * 1.5,
      height: bookSize,
    );
    
    paint.color = Colors.white.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bookRect, Radius.circular(bookSize * 0.1)),
      paint,
    );
    
    // Kitob ichidagi chiziqlar
    paint.color = AppColors.brandBlue1;
    paint.strokeWidth = size * 0.008;
    final lineSpacing = bookSize * 0.2;
    for (int i = 0; i < 3; i++) {
      final lineY = bookRect.top + lineSpacing + (i * lineSpacing);
      canvas.drawLine(
        Offset(bookRect.left + bookSize * 0.2, lineY),
        Offset(bookRect.right - bookSize * 0.2, lineY),
        paint,
      );
    }
  }
  
  /// PNG formatida bytes qaytaradi
  static Future<Uint8List> generateAppIconPng(double size) async {
    final image = await generateAppIcon(size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}