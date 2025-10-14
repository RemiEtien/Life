import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/emotion_colors.dart';

/// Базовый класс для всех эффектов эмоций
abstract class EmotionEffectPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0, animation progress
  final double intensity; // 0.0 to 1.0, effect intensity
  final Size screenSize;

  EmotionEffectPainter({
    required this.progress,
    required this.intensity,
    required this.screenSize,
  });

  @override
  bool shouldRepaint(covariant EmotionEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.intensity != intensity;
  }
}

/// Фабрика для создания painter'ов эффектов
class EmotionEffectFactory {
  static EmotionEffectPainter createPainter({
    required String emotion,
    required double progress,
    required double intensity,
    required Size screenSize,
  }) {
    if (kDebugMode) {
      debugPrint('🎨 EmotionEffectFactory: Creating painter for emotion="$emotion", intensity=$intensity, progress=$progress');
    }

    switch (emotion) {
      case 'joy':
        return JoyEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'sadness':
        return SadnessEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'anger':
        if (kDebugMode) {
          debugPrint('🔥 Creating AngerEffectPainter');
        }
        return AngerEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'fear':
        if (kDebugMode) {
          debugPrint('👻 Creating FearEffectPainter');
        }
        return FearEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'disgust':
        if (kDebugMode) {
          debugPrint('🤢 Creating DisgustEffectPainter');
        }
        return DisgustEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'surprise':
        return SurpriseEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'love':
        return LoveEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      case 'pride':
        if (kDebugMode) {
          debugPrint('👑 Creating PrideEffectPainter');
        }
        return PrideEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
      default:
        if (kDebugMode) {
          debugPrint('⚠️ Unknown emotion "$emotion", using JoyEffectPainter as fallback');
        }
        return JoyEffectPainter(
          progress: progress,
          intensity: intensity,
          screenSize: screenSize,
        );
    }
  }
}

// ============================================================================
// JOY - Солнечные лучи и золотые частицы
// ============================================================================
class JoyEffectPainter extends EmotionEffectPainter {
  JoyEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGoldenGlow(canvas, size);
    _drawSunRays(canvas, size);
    _drawGoldenParticles(canvas, size);
  }

  // Золотистое свечение фоном
  void _drawGoldenGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, -size.height * 0.2);
    final radius = size.height * 1.5;

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          EmotionColors.joy.withOpacity(0.15 * intensity),
          EmotionColors.joy.withOpacity(0.08 * intensity),
          EmotionColors.joy.withOpacity(0.0),
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  // Солнечные лучи (god rays)
  void _drawSunRays(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, -size.height * 0.2);
    const numRays = 12;

    for (int i = 0; i < numRays; i++) {
      final angle = (i / numRays) * pi * 2 + progress * pi * 0.1;
      final rayWidth = 30.0 + sin(progress * pi * 2 + i) * 10.0;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + cos(angle - rayWidth / 200) * size.height * 2,
          center.dy + sin(angle - rayWidth / 200) * size.height * 2,
        )
        ..lineTo(
          center.dx + cos(angle + rayWidth / 200) * size.height * 2,
          center.dy + sin(angle + rayWidth / 200) * size.height * 2,
        )
        ..close();

      final rayPaint = Paint()
        ..shader = ui.Gradient.linear(
          center,
          Offset(
            center.dx + cos(angle) * size.height,
            center.dy + sin(angle) * size.height,
          ),
          [
            EmotionColors.joy.withOpacity(0.2 * intensity),
            EmotionColors.joy.withOpacity(0.05 * intensity),
            EmotionColors.joy.withOpacity(0.0),
          ],
          [0.0, 0.6, 1.0],
        );

      canvas.drawPath(path, rayPaint);
    }
  }

  // Золотые частицы пыли
  void _drawGoldenParticles(Canvas canvas, Size size) {
    final particleCount = (50 * intensity).toInt();

    for (int i = 0; i < particleCount; i++) {
      final particleRandom = Random(i + 42);

      final x = particleRandom.nextDouble() * size.width;
      final baseY = particleRandom.nextDouble() * size.height;
      final speed = 0.1 + particleRandom.nextDouble() * 0.2;
      final offset = (progress * speed) % 1.0;
      final y = (baseY + offset * size.height * 0.3) % size.height;

      final particleSize = 2.0 + particleRandom.nextDouble() * 4.0;
      final opacity = (0.4 + sin(progress * pi * 2 + i) * 0.3).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = EmotionColors.joy.withOpacity(opacity * intensity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
}

// ============================================================================
// SADNESS - Настоящий дождь
// ============================================================================
class SadnessEffectPainter extends EmotionEffectPainter {
  SadnessEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawFog(canvas, size);
    _drawRainDrops(canvas, size);
    _drawRainRipples(canvas, size);
  }

  // Туман внизу
  void _drawFog(Canvas canvas, Size size) {
    final fogHeight = size.height * 0.3;
    final fogPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset(0, size.height - fogHeight),
        [
          EmotionColors.sadness.withOpacity(0.2 * intensity),
          EmotionColors.sadness.withOpacity(0.0),
        ],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - fogHeight, size.width, fogHeight),
      fogPaint,
    );
  }

  // Капли дождя
  void _drawRainDrops(Canvas canvas, Size size) {
    const dropCount = 120;

    for (int i = 0; i < dropCount; i++) {
      final dropRandom = Random(i + 100);
      final x = dropRandom.nextDouble() * size.width;
      final speed = 0.8 + dropRandom.nextDouble() * 0.4;
      final length = 25.0 + dropRandom.nextDouble() * 40.0;

      final offset = (progress * speed) % 1.0;
      final y = (dropRandom.nextDouble() * size.height + offset * size.height * 1.2) % (size.height + length);

      const angle = -pi / 2 + 0.1; // Slight angle
      final endX = x + cos(angle) * length;
      final endY = y + sin(angle) * length;

      final dropPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, y),
          Offset(endX, endY),
          [
            Colors.white.withOpacity(0.7 * intensity),
            EmotionColors.sadness.withOpacity(0.6 * intensity),
            EmotionColors.sadness.withOpacity(0.1 * intensity),
          ],
          [0.0, 0.5, 1.0],
        )
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, y), Offset(endX, endY), dropPaint);
    }
  }

  // Рябь от капель
  void _drawRainRipples(Canvas canvas, Size size) {
    const rippleCount = 15;

    for (int i = 0; i < rippleCount; i++) {
      final rippleRandom = Random(i + 500);
      final x = rippleRandom.nextDouble() * size.width;
      final cycleProgress = (progress * 2 + rippleRandom.nextDouble()) % 1.0;

      // Ripples only at bottom
      final y = size.height - 50 - rippleRandom.nextDouble() * 100;

      const maxRadius = 20.0;
      final radius = cycleProgress * maxRadius;
      final opacity = (1.0 - cycleProgress) * 0.4;

      final ripplePaint = Paint()
        ..color = EmotionColors.sadness.withOpacity(opacity * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(Offset(x, y), radius, ripplePaint);

      // Double ripple for effect
      if (cycleProgress > 0.3) {
        final radius2 = (cycleProgress - 0.3) * maxRadius;
        final opacity2 = (1.0 - cycleProgress) * 0.2;
        final ripplePaint2 = Paint()
          ..color = EmotionColors.sadness.withOpacity(opacity2 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(x, y), radius2, ripplePaint2);
      }
    }
  }
}

// ============================================================================
// ANGER - Молнии и огонь
// ============================================================================
class AngerEffectPainter extends EmotionEffectPainter {
  AngerEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRedGlow(canvas, size);
    _drawLightning(canvas, size);
    _drawEmbers(canvas, size);
  }

  // Красное пульсирующее свечение
  void _drawRedGlow(Canvas canvas, Size size) {
    final pulseFactor = 0.7 + sin(progress * pi * 4) * 0.3;
    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width * 1.2,
        [
          EmotionColors.anger.withOpacity(0.5 * intensity * pulseFactor),
          EmotionColors.anger.withOpacity(0.3 * intensity * pulseFactor),
          EmotionColors.anger.withOpacity(0.1 * intensity * pulseFactor),
          EmotionColors.anger.withOpacity(0.0),
        ],
        [0.0, 0.4, 0.7, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  // Молнии
  void _drawLightning(Canvas canvas, Size size) {
    // Lightning strikes every 2 seconds
    final strikePhase = (progress * 7.5) % 1.0;

    if (strikePhase < 0.2) {
      // Show lightning for brief moment
      final lightningRandom = Random((progress * 100).toInt() + 200);
      _drawSingleLightning(canvas, size, lightningRandom);
    }
  }

  void _drawSingleLightning(Canvas canvas, Size size, Random random) {
    final startX = random.nextDouble() * size.width;
    const startY = 0.0;

    final path = Path()..moveTo(startX, startY);

    var currentX = startX;
    var currentY = startY;
    const segments = 15;
    const segmentLength = 40.0;

    for (int i = 0; i < segments; i++) {
      final angle = pi / 2 + (random.nextDouble() - 0.5) * 0.8;
      currentX += cos(angle) * segmentLength;
      currentY += sin(angle) * segmentLength;

      if (currentY > size.height) break;

      path.lineTo(currentX, currentY);
    }

    final lightningPaint = Paint()
      ..color = Colors.white.withOpacity(1.0 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10.0);

    canvas.drawPath(path, lightningPaint);

    // Glow around lightning
    final glowPaint = Paint()
      ..color = EmotionColors.anger.withOpacity(0.8 * intensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0);

    canvas.drawPath(path, glowPaint);
  }

  // Огненные угольки летящие вверх
  void _drawEmbers(Canvas canvas, Size size) {
    const emberCount = 80;

    for (int i = 0; i < emberCount; i++) {
      final emberRandom = Random(i + 300);
      final x = emberRandom.nextDouble() * size.width;
      final speed = 0.3 + emberRandom.nextDouble() * 0.5;

      final offset = (progress * speed) % 1.0;
      final baseY = size.height + emberRandom.nextDouble() * 100;
      final y = baseY - offset * size.height * 1.3;

      if (y > size.height || y < -20) continue;

      final emberSize = 3.0 + emberRandom.nextDouble() * 6.0;
      final flicker = sin(progress * pi * 8 + i) * 0.3 + 0.7;
      final opacity = (1.0 - offset) * flicker;

      final emberPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          emberSize * 3,
          [
            Colors.white.withOpacity(opacity * intensity),
            const Color(0xFFFF8C00).withOpacity(opacity * 0.9 * intensity),
            EmotionColors.anger.withOpacity(opacity * 0.8 * intensity),
            EmotionColors.anger.withOpacity(0.0),
          ],
          [0.0, 0.3, 0.7, 1.0],
        )
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0);

      canvas.drawCircle(Offset(x, y), emberSize * 3, emberPaint);
    }
  }
}

// ============================================================================
// FEAR - Мистический туман
// ============================================================================
class FearEffectPainter extends EmotionEffectPainter {
  FearEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawFogLayers(canvas, size);
    _drawPulsingLights(canvas, size);
    _drawShadows(canvas, size);
  }

  // Волнообразный туман
  void _drawFogLayers(Canvas canvas, Size size) {
    const layerCount = 5;

    for (int i = 0; i < layerCount; i++) {
      final layerOffset = (progress * 0.2 + i * 0.2) % 1.0;
      final layerHeight = size.height * (0.4 + i * 0.15);

      final path = Path();
      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x += 20) {
        final waveHeight = sin((x / size.width) * pi * 2 + layerOffset * pi * 2) * 30.0;
        final y = size.height - layerHeight + waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      final fogPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, size.height - layerHeight),
          Offset(0, size.height),
          [
            EmotionColors.fear.withOpacity(0.25 * intensity * (1.0 - i / layerCount)),
            EmotionColors.fear.withOpacity(0.45 * intensity),
          ],
        );

      canvas.drawPath(path, fogPaint);
    }
  }

  // Пульсирующие огоньки в тумане
  void _drawPulsingLights(Canvas canvas, Size size) {
    const lightCount = 15;

    for (int i = 0; i < lightCount; i++) {
      final lightRandom = Random(i + 600);
      final x = lightRandom.nextDouble() * size.width;
      final y = size.height * (0.2 + lightRandom.nextDouble() * 0.7);

      final pulse = sin(progress * pi * 2 + i * 0.5) * 0.5 + 0.5;
      final radius = 25.0 + pulse * 20.0;

      final lightPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius * 2,
          [
            Colors.white.withOpacity(0.9 * pulse * intensity),
            EmotionColors.fear.withOpacity(0.7 * pulse * intensity),
            EmotionColors.fear.withOpacity(0.3 * pulse * intensity),
            EmotionColors.fear.withOpacity(0.0),
          ],
          [0.0, 0.3, 0.6, 1.0],
        )
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6.0);

      canvas.drawCircle(Offset(x, y), radius * 2, lightPaint);
    }
  }

  // Темные тени проплывающие
  void _drawShadows(Canvas canvas, Size size) {
    const shadowCount = 4;

    for (int i = 0; i < shadowCount; i++) {
      final shadowRandom = Random(i + 700);
      final speed = 0.15 + shadowRandom.nextDouble() * 0.1;
      final offset = (progress * speed) % 1.0;

      final x = (shadowRandom.nextDouble() * size.width * 1.5 - size.width * 0.25 + offset * size.width) % (size.width * 1.2);
      final y = size.height * (0.2 + shadowRandom.nextDouble() * 0.6);
      final width = 80.0 + shadowRandom.nextDouble() * 60.0;
      final height = 150.0 + shadowRandom.nextDouble() * 100.0;

      final shadowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          width,
          [
            Colors.black.withOpacity(0.5 * intensity),
            Colors.black.withOpacity(0.1 * intensity),
            Colors.black.withOpacity(0.0),
          ],
          [0.0, 0.6, 1.0],
        );

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: width, height: height),
        shadowPaint,
      );
    }
  }
}

// ============================================================================
// DISGUST - Токсичные пузыри
// ============================================================================
class DisgustEffectPainter extends EmotionEffectPainter {
  DisgustEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawToxicHaze(canvas, size);
    _drawBubbles(canvas, size);
    _drawSlime(canvas, size);
  }

  // Токсичная дымка внизу
  void _drawToxicHaze(Canvas canvas, Size size) {
    final hazeHeight = size.height * 0.6;
    final pulseFactor = 0.8 + sin(progress * pi * 3) * 0.2;
    final hazePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset(0, size.height - hazeHeight),
        [
          EmotionColors.disgust.withOpacity(0.65 * intensity * pulseFactor),
          EmotionColors.disgust.withOpacity(0.45 * intensity * pulseFactor),
          EmotionColors.disgust.withOpacity(0.2 * intensity * pulseFactor),
          EmotionColors.disgust.withOpacity(0.0),
        ],
        [0.0, 0.4, 0.7, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - hazeHeight, size.width, hazeHeight),
      hazePaint,
    );
  }

  // Пузыри поднимающиеся и лопающиеся
  void _drawBubbles(Canvas canvas, Size size) {
    const bubbleCount = 40;

    for (int i = 0; i < bubbleCount; i++) {
      final bubbleRandom = Random(i + 800);
      final x = bubbleRandom.nextDouble() * size.width;
      final speed = 0.2 + bubbleRandom.nextDouble() * 0.3;
      final baseSize = 15.0 + bubbleRandom.nextDouble() * 30.0;

      final offset = (progress * speed) % 1.0;
      final baseY = size.height + 50;
      final y = baseY - offset * (size.height + 100);

      if (y < -50) continue;

      // Bubble pops near top
      final popProgress = ((offset - 0.8) / 0.2).clamp(0.0, 1.0);
      final bubbleSize = baseSize * (1.0 + popProgress * 0.5);
      final bubbleOpacity = 1.0 - popProgress;

      // Bubble wobble
      final wobble = sin(progress * pi * 4 + i) * 8.0;

      // Bubble gradient
      final bubblePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x + wobble, y),
          bubbleSize,
          [
            EmotionColors.disgust.withOpacity(0.6 * bubbleOpacity * intensity),
            EmotionColors.disgust.withOpacity(0.8 * bubbleOpacity * intensity),
            EmotionColors.disgust.withOpacity(0.4 * bubbleOpacity * intensity),
          ],
          [0.0, 0.7, 1.0],
        );

      canvas.drawCircle(Offset(x + wobble, y), bubbleSize, bubblePaint);

      // Highlight
      final highlightPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x + wobble - bubbleSize * 0.3, y - bubbleSize * 0.3),
          bubbleSize * 0.3,
          [
            Colors.white.withOpacity(0.8 * bubbleOpacity * intensity),
            Colors.white.withOpacity(0.2 * bubbleOpacity * intensity),
          ],
        );

      canvas.drawCircle(
        Offset(x + wobble - bubbleSize * 0.3, y - bubbleSize * 0.3),
        bubbleSize * 0.3,
        highlightPaint,
      );
    }
  }

  // Слизь стекающая сверху
  void _drawSlime(Canvas canvas, Size size) {
    const slimeCount = 12;

    for (int i = 0; i < slimeCount; i++) {
      final slimeRandom = Random(i + 900);
      final x = slimeRandom.nextDouble() * size.width;
      final speed = 0.08 + slimeRandom.nextDouble() * 0.08;
      final maxLength = 50.0 + slimeRandom.nextDouble() * 80.0;

      final offset = (progress * speed) % 1.0;
      final length = offset * maxLength;

      final slimePaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(x, 0),
          Offset(x, length),
          [
            EmotionColors.disgust.withOpacity(0.9 * intensity),
            EmotionColors.disgust.withOpacity(0.6 * intensity),
            EmotionColors.disgust.withOpacity(0.2 * intensity),
          ],
          [0.0, 0.5, 1.0],
        )
        ..strokeWidth = 4.0 + slimeRandom.nextDouble() * 5.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, 0), Offset(x, length), slimePaint);

      // Drip at end
      if (length > 10) {
        final dripPaint = Paint()
          ..color = EmotionColors.disgust.withOpacity(0.8 * intensity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, length), 5.0, dripPaint);
      }
    }
  }
}

// ============================================================================
// SURPRISE - Фейерверк
// ============================================================================
class SurpriseEffectPainter extends EmotionEffectPainter {
  SurpriseEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawFireworks(canvas, size);
    _drawConfetti(canvas, size);
  }

  void _drawFireworks(Canvas canvas, Size size) {
    const fireworkCount = 3;

    for (int i = 0; i < fireworkCount; i++) {
      final fireworkRandom = Random(i + 1000);
      final cycleProgress = (progress * 2 + i * 0.33) % 1.0;

      if (cycleProgress > 0.7) continue;

      final centerX = 0.2 + fireworkRandom.nextDouble() * 0.6;
      final centerY = 0.2 + fireworkRandom.nextDouble() * 0.4;
      final center = Offset(size.width * centerX, size.height * centerY);

      if (cycleProgress > 0.2) {
        final explosionProgress = (cycleProgress - 0.2) / 0.5;
        const particleCount = 40;

        for (int j = 0; j < particleCount; j++) {
          final angle = (j / particleCount) * pi * 2;
          final distance = explosionProgress * 80.0;
          final opacity = (1.0 - explosionProgress) * 0.8;

          final particlePos = Offset(
            center.dx + cos(angle) * distance,
            center.dy + sin(angle) * distance,
          );

          final particlePaint = Paint()
            ..color = EmotionColors.surprise.withOpacity(opacity * intensity)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.0);

          canvas.drawCircle(particlePos, 3.0, particlePaint);
        }

        if (cycleProgress < 0.3) {
          final flashOpacity = 1.0 - (cycleProgress - 0.2) / 0.1;
          final flashPaint = Paint()
            ..color = Colors.white.withOpacity(flashOpacity * 0.6 * intensity)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0);

          canvas.drawCircle(center, 30.0, flashPaint);
        }
      }
    }
  }

  void _drawConfetti(Canvas canvas, Size size) {
    const confettiCount = 50;

    for (int i = 0; i < confettiCount; i++) {
      final confettiRandom = Random(i + 1100);
      final x = confettiRandom.nextDouble() * size.width;
      final speed = 0.3 + confettiRandom.nextDouble() * 0.4;
      final rotation = confettiRandom.nextDouble() * pi * 2;
      final rotationSpeed = (confettiRandom.nextDouble() - 0.5) * 3.0;

      final offset = (progress * speed) % 1.0;
      const baseY = -50.0;
      final y = baseY + offset * (size.height + 100);

      if (y > size.height + 50) continue;

      final currentRotation = rotation + progress * rotationSpeed;
      const confettiWidth = 8.0;
      const confettiHeight = 15.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      final confettiPaint = Paint()
        ..color = EmotionColors.surprise.withOpacity(0.8 * intensity)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: confettiWidth, height: confettiHeight),
        confettiPaint,
      );

      canvas.restore();
    }
  }
}

// ============================================================================
// LOVE - Лепестки сакуры
// ============================================================================
class LoveEffectPainter extends EmotionEffectPainter {
  LoveEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBokeh(canvas, size);
    _drawPetals(canvas, size);
    _drawHeartBubbles(canvas, size);
  }

  void _drawBokeh(Canvas canvas, Size size) {
    const bokehCount = 15;
    for (int i = 0; i < bokehCount; i++) {
      final bokehRandom = Random(i + 1200);
      final x = bokehRandom.nextDouble() * size.width;
      final y = bokehRandom.nextDouble() * size.height;
      final radius = 20.0 + bokehRandom.nextDouble() * 40.0;
      final pulse = sin(progress * pi * 2 + i) * 0.3 + 0.7;

      final bokehPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          radius,
          [
            EmotionColors.love.withOpacity(0.0),
            EmotionColors.love.withOpacity(0.15 * pulse * intensity),
            EmotionColors.love.withOpacity(0.0),
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawCircle(Offset(x, y), radius, bokehPaint);
    }
  }

  void _drawPetals(Canvas canvas, Size size) {
    const petalCount = 30;
    for (int i = 0; i < petalCount; i++) {
      final petalRandom = Random(i + 1300);
      final baseX = petalRandom.nextDouble() * size.width;
      final speed = 0.15 + petalRandom.nextDouble() * 0.2;
      final swayAmplitude = 30.0 + petalRandom.nextDouble() * 40.0;
      final rotation = petalRandom.nextDouble() * pi * 2;
      final rotationSpeed = (petalRandom.nextDouble() - 0.5) * 2.0;

      final offset = (progress * speed) % 1.0;
      final y = -20.0 + offset * (size.height + 40);
      final swayOffset = sin(offset * pi * 4) * swayAmplitude;
      final x = baseX + swayOffset;

      if (y > size.height + 20) continue;

      final currentRotation = rotation + progress * rotationSpeed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentRotation);

      _drawPetal(canvas, 8.0, EmotionColors.love.withOpacity(0.8 * intensity));

      canvas.restore();
    }
  }

  void _drawPetal(Canvas canvas, double size, Color color) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size, -size * 0.5, size, 0);
    path.quadraticBezierTo(size, size * 0.5, 0, size);
    path.quadraticBezierTo(-size, size * 0.5, -size, 0);
    path.quadraticBezierTo(-size, -size * 0.5, 0, 0);

    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, petalPaint);
  }

  void _drawHeartBubbles(Canvas canvas, Size size) {
    const heartCount = 10;
    for (int i = 0; i < heartCount; i++) {
      final heartRandom = Random(i + 1400);
      final x = heartRandom.nextDouble() * size.width;
      final speed = 0.2 + heartRandom.nextDouble() * 0.3;

      final offset = (progress * speed) % 1.0;
      final y = size.height + 20 - offset * (size.height + 40);

      if (y < -20) continue;

      final heartSize = 6.0 + heartRandom.nextDouble() * 8.0;
      final opacity = (1.0 - offset) * 0.6;

      canvas.save();
      canvas.translate(x, y);
      _drawHeart(canvas, heartSize, EmotionColors.love.withOpacity(opacity * intensity));
      canvas.restore();
    }
  }

  void _drawHeart(Canvas canvas, double size, Color color) {
    final path = Path();
    path.moveTo(0, size * 0.3);
    path.cubicTo(-size * 0.7, -size * 0.4, -size * 1.5, size * 0.3, 0, size * 1.2);
    path.cubicTo(size * 1.5, size * 0.3, size * 0.7, -size * 0.4, 0, size * 0.3);

    final heartPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, heartPaint);
  }
}

// ============================================================================
// PRIDE - Королевский фонтан
// ============================================================================
class PrideEffectPainter extends EmotionEffectPainter {
  PrideEffectPainter({
    required super.progress,
    required super.intensity,
    required super.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawShimmer(canvas, size);
    _drawFountainParticles(canvas, size);
    _drawGlitter(canvas, size);
  }

  void _drawShimmer(Canvas canvas, Size size) {
    final shimmerProgress = (progress * 2) % 1.0;
    final shimmerX = shimmerProgress * size.width * 1.5 - size.width * 0.25;

    final shimmerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(shimmerX - 150, 0),
        Offset(shimmerX + 150, size.height),
        [
          EmotionColors.pride.withOpacity(0.0),
          EmotionColors.pride.withOpacity(0.4 * intensity),
          Colors.white.withOpacity(0.5 * intensity),
          EmotionColors.pride.withOpacity(0.4 * intensity),
          EmotionColors.pride.withOpacity(0.0),
        ],
        [0.0, 0.3, 0.5, 0.7, 1.0],
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), shimmerPaint);
  }

  void _drawFountainParticles(Canvas canvas, Size size) {
    const particleCount = 60;
    final centerX = size.width * 0.5;
    final bottomY = size.height;

    for (int i = 0; i < particleCount; i++) {
      final particleRandom = Random(i + 1500);
      final angle = -pi / 2 + (particleRandom.nextDouble() - 0.5) * pi * 0.6;
      final speed = 0.4 + particleRandom.nextDouble() * 0.6;
      final maxHeight = size.height * (0.4 + particleRandom.nextDouble() * 0.4);

      final offset = (progress * speed) % 1.0;
      final trajectory = offset * 2.0;
      final actualOffset = trajectory > 1.0 ? 2.0 - trajectory : trajectory;

      final distance = actualOffset * maxHeight;
      final x = centerX + cos(angle) * distance;
      final y = bottomY - sin(angle).abs() * distance;

      if (y > size.height || y < 0) continue;

      final particleSize = 3.0 + particleRandom.nextDouble() * 3.0;
      final opacity = (1.0 - actualOffset) * 0.8;

      final isGold = particleRandom.nextDouble() > 0.5;
      final particleColor = isGold ? const Color(0xFFFFD700) : EmotionColors.pride;

      final particlePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          particleSize * 2,
          [
            Colors.white.withOpacity(opacity * 0.8 * intensity),
            particleColor.withOpacity(opacity * intensity),
            particleColor.withOpacity(opacity * 0.5 * intensity),
            particleColor.withOpacity(0.0),
          ],
          [0.0, 0.3, 0.6, 1.0],
        )
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.0);

      canvas.drawCircle(Offset(x, y), particleSize * 2, particlePaint);
    }
  }

  void _drawGlitter(Canvas canvas, Size size) {
    const glitterCount = 60;

    for (int i = 0; i < glitterCount; i++) {
      final glitterRandom = Random(i + 1600);
      final x = glitterRandom.nextDouble() * size.width;
      final y = glitterRandom.nextDouble() * size.height;
      final twinkleSpeed = 2.0 + glitterRandom.nextDouble() * 3.0;
      final twinkle = sin(progress * pi * twinkleSpeed + i) * 0.5 + 0.5;

      if (twinkle < 0.2) continue;

      final glitterSize = 3.0 + twinkle * 5.0;
      final glitterPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(x, y),
          glitterSize * 3,
          [
            Colors.white.withOpacity(twinkle * intensity),
            const Color(0xFFFFD700).withOpacity(twinkle * 0.9 * intensity),
            EmotionColors.pride.withOpacity(twinkle * 0.7 * intensity),
            EmotionColors.pride.withOpacity(0.0),
          ],
          [0.0, 0.3, 0.6, 1.0],
        )
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.0);

      canvas.drawCircle(Offset(x, y), glitterSize * 3, glitterPaint);

      _drawStar(canvas, Offset(x, y), glitterSize * 3, Colors.white.withOpacity(twinkle * 0.9 * intensity));
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (pi / 2) * i;
      final x = center.dx + cos(angle) * size;
      final y = center.dy + sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, starPaint);
  }
}
