import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../memory.dart';
import '../utils/emotion_colors.dart';

/// Погодные эффекты как круговые ауры вокруг каждого воспоминания (только при zoom > 3.0)
class TimelineWeatherEffects extends StatefulWidget {
  final List<Memory> visibleMemories;
  final double zoomScale;

  const TimelineWeatherEffects({
    super.key,
    required this.visibleMemories,
    required this.zoomScale,
  });

  @override
  State<TimelineWeatherEffects> createState() => _TimelineWeatherEffectsState();
}

class _TimelineWeatherEffectsState extends State<TimelineWeatherEffects>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<String, List<MemoryAuraParticle>> _memoryParticles = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _initializeParticles();
  }

  @override
  void didUpdateWidget(TimelineWeatherEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visibleMemories != widget.visibleMemories ||
        oldWidget.zoomScale != widget.zoomScale) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    _memoryParticles.clear();

    if (kDebugMode) {
      debugPrint('[WEATHER] Init: zoom=${widget.zoomScale.toStringAsFixed(2)}, memories=${widget.visibleMemories.length}');
    }

    if (widget.zoomScale > 0.8) {
      if (kDebugMode) debugPrint('[WEATHER] SKIPPED - zoom > 0.8 (too far out)');
      return;
    }

    // Создаем частицы для каждого воспоминания с эмоцией
    int totalParticles = 0;
    for (final memory in widget.visibleMemories) {
      if (memory.primaryEmotion == null) continue;

      final memoryId = memory.universalId;
      final particles = <MemoryAuraParticle>[];

      // Количество частиц на ауру: 10-20 в зависимости от intensity
      final particleCount = (10 + memory.emotionIntensity * 10).round();
      totalParticles += particleCount;

      for (int i = 0; i < particleCount; i++) {
        particles.add(_createParticle(memory.primaryEmotion!));
      }

      _memoryParticles[memoryId] = particles;
    }

    if (kDebugMode) {
      debugPrint('[WEATHER] Created $totalParticles particles for ${_memoryParticles.length} memories');
    }
  }

  MemoryAuraParticle _createParticle(String emotion) {
    // Случайный угол для круговой ауры
    final angle = _random.nextDouble() * 2 * pi;
    // Расстояние от центра (0.3 - 1.0 радиуса ауры)
    final distance = _random.nextDouble() * 0.7 + 0.3;

    return MemoryAuraParticle(
      angle: angle,
      distance: distance,
      velocityAngle: _getAngularVelocity(emotion),
      velocityDistance: _getDistanceVelocity(emotion),
      size: _random.nextDouble() * 2 + 1,
      opacity: _random.nextDouble() * 0.4 + 0.3,
      lifetime: _random.nextDouble(), // 0.0 - 1.0
    );
  }

  double _getAngularVelocity(String emotion) {
    switch (emotion) {
      case 'joy':
        return 0.02; // быстрое вращение
      case 'anger':
        return 0.05; // очень быстрое
      case 'sadness':
        return 0.005; // медленное
      case 'fear':
        return -0.01; // обратное медленное
      default:
        return 0.01;
    }
  }

  double _getDistanceVelocity(String emotion) {
    switch (emotion) {
      case 'joy':
        return 0.01; // расширяется
      case 'anger':
        return 0.02; // быстро расширяется
      case 'sadness':
        return -0.005; // сжимается
      case 'love':
        return 0.008; // медленно расширяется
      default:
        return 0.005;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Не показываем эффекты если zoom < 3.0
    if (widget.zoomScale < 3.0 || _memoryParticles.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: _MemoryAuraPainter(
            memories: widget.visibleMemories,
            memoryParticles: _memoryParticles,
            zoomScale: widget.zoomScale,
          ),
          child: Container(),
        );
      },
    );
  }

  void _updateParticles() {
    for (final particles in _memoryParticles.values) {
      for (var particle in particles) {
        // Обновляем угол (вращение)
        particle.angle += particle.velocityAngle;
        if (particle.angle > 2 * pi) particle.angle -= 2 * pi;
        if (particle.angle < 0) particle.angle += 2 * pi;

        // Обновляем расстояние (пульсация)
        particle.distance += particle.velocityDistance;

        // Респаун если вышли за границы
        if (particle.distance > 1.0) {
          particle.distance = 0.3;
        } else if (particle.distance < 0.3) {
          particle.distance = 1.0;
        }

        // Обновляем lifetime для fade эффекта
        particle.lifetime += 0.01;
        if (particle.lifetime > 1.0) particle.lifetime = 0.0;
      }
    }
  }
}

class MemoryAuraParticle {
  double angle; // радианы
  double distance; // 0.0 (центр) - 1.0 (край ауры)
  double velocityAngle; // скорость вращения
  double velocityDistance; // скорость расширения/сжатия
  double size;
  double opacity;
  double lifetime; // 0.0 - 1.0 для fade эффектов

  MemoryAuraParticle({
    required this.angle,
    required this.distance,
    required this.velocityAngle,
    required this.velocityDistance,
    required this.size,
    required this.opacity,
    required this.lifetime,
  });
}

class _MemoryAuraPainter extends CustomPainter {
  final List<Memory> memories;
  final Map<String, List<MemoryAuraParticle>> memoryParticles;
  final double zoomScale;

  _MemoryAuraPainter({
    required this.memories,
    required this.memoryParticles,
    required this.zoomScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Радиус ауры зависит от zoom (больше zoom = больше аура)
    final auraRadius = 40.0 * (zoomScale / 3.0).clamp(1.0, 3.0);

    for (final memory in memories) {
      if (memory.primaryEmotion == null) continue;

      final memoryId = memory.universalId;
      final particles = memoryParticles[memoryId];
      if (particles == null || particles.isEmpty) continue;

      // Позиция воспоминания на Timeline (нужно получить из layout)
      // ВРЕМЕННО: используем фиксированные позиции для демонстрации
      // В реальности нужно получить координаты из LifelineWidget
      final memoryPos = _getMemoryPosition(memory, size);

      // Рисуем круговую ауру (слабое свечение)
      _drawAuraGlow(canvas, memoryPos, auraRadius, memory.primaryEmotion!);

      // Рисуем частицы вокруг воспоминания
      final paint = Paint()..style = PaintingStyle.fill;

      for (var particle in particles) {
        // Конвертируем полярные координаты в декартовы
        final x = memoryPos.dx + cos(particle.angle) * particle.distance * auraRadius;
        final y = memoryPos.dy + sin(particle.angle) * particle.distance * auraRadius;
        final pos = Offset(x, y);

        // Fade эффект на основе lifetime
        final fadeOpacity = sin(particle.lifetime * pi) * particle.opacity;
        paint.color = _getEmotionColor(memory.primaryEmotion!).withOpacity(fadeOpacity);

        // Рисуем частицу в зависимости от эмоции
        _drawParticle(canvas, pos, particle.size, memory.primaryEmotion!, paint);
      }
    }
  }

  Offset _getMemoryPosition(Memory memory, Size size) {
    // Равномерное распределение воспоминаний по вертикали
    final index = memories.indexOf(memory);
    if (index == -1) return Offset(size.width / 2, size.height / 2);

    final spacing = size.height / (memories.length + 1);
    return Offset(size.width / 2, spacing * (index + 1));
  }

  void _drawAuraGlow(Canvas canvas, Offset center, double radius, String emotion) {
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _getEmotionColor(emotion).withOpacity(0.15),
          _getEmotionColor(emotion).withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, glowPaint);
  }

  void _drawParticle(Canvas canvas, Offset pos, double size, String emotion, Paint paint) {
    switch (emotion) {
      case 'sadness':
        _drawRaindrop(canvas, pos, size, paint);
        break;
      case 'anger':
        _drawSpark(canvas, pos, size, paint);
        break;
      case 'joy':
        _drawSparkle(canvas, pos, size, paint);
        break;
      case 'love':
        _drawHeart(canvas, pos, size, paint);
        break;
      case 'fear':
        canvas.drawCircle(pos, size * 1.5, paint); // fog
        break;
      default:
        canvas.drawCircle(pos, size, paint);
    }
  }

  Color _getEmotionColor(String emotion) {
    return EmotionColors.getColor(emotion);
  }

  void _drawRaindrop(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy - size)
      ..quadraticBezierTo(pos.dx + size * 0.5, pos.dy, pos.dx, pos.dy + size)
      ..quadraticBezierTo(pos.dx - size * 0.5, pos.dy, pos.dx, pos.dy - size);
    canvas.drawPath(path, paint);
  }

  void _drawSpark(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy - size * 1.5)
      ..lineTo(pos.dx + size * 0.3, pos.dy)
      ..lineTo(pos.dx, pos.dy + size * 1.5)
      ..lineTo(pos.dx - size * 0.3, pos.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkle(Canvas canvas, Offset pos, double size, Paint paint) {
    paint.strokeWidth = 1;
    canvas.drawLine(
      Offset(pos.dx - size, pos.dy),
      Offset(pos.dx + size, pos.dy),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - size),
      Offset(pos.dx, pos.dy + size),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx - size * 0.7, pos.dy - size * 0.7),
      Offset(pos.dx + size * 0.7, pos.dy + size * 0.7),
      paint,
    );
    canvas.drawLine(
      Offset(pos.dx - size * 0.7, pos.dy + size * 0.7),
      Offset(pos.dx + size * 0.7, pos.dy - size * 0.7),
      paint,
    );
  }

  void _drawHeart(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy + size);
    path.cubicTo(
      pos.dx - size * 1.5, pos.dy - size * 0.5,
      pos.dx - size, pos.dy - size * 1.5,
      pos.dx, pos.dy - size * 0.5,
    );
    path.cubicTo(
      pos.dx + size, pos.dy - size * 1.5,
      pos.dx + size * 1.5, pos.dy - size * 0.5,
      pos.dx, pos.dy + size,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MemoryAuraPainter oldDelegate) => true;
}
