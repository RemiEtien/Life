import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/emotion_colors.dart';

/// Система частиц для эмоциональных эффектов
class EmotionParticlesWidget extends StatefulWidget {
  final String emotion;
  final double intensity;

  const EmotionParticlesWidget({
    super.key,
    required this.emotion,
    required this.intensity,
  });

  @override
  State<EmotionParticlesWidget> createState() => _EmotionParticlesWidgetState();
}

class _EmotionParticlesWidgetState extends State<EmotionParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
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

  void _initializeParticles() {
    // Оптимизировано: 14-42 частицы (70% от предыдущего)
    final particleCount = (35 * widget.intensity).round().clamp(14, 42);

    for (int i = 0; i < particleCount; i++) {
      _particles.add(_createParticle());
    }
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      velocityY: _getVelocityForEmotion(),
      velocityX: (_random.nextDouble() - 0.5) * 0.04, // Увеличено горизонтальное движение
      size: _random.nextDouble() * 5 + 3, // Увеличено: 3-8px (было 1-4px)
      opacity: _random.nextDouble() * 0.5 + 0.4, // Более видимые (0.4-0.9)
      rotation: _random.nextDouble() * pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.15, // Быстрее вращение
      shape: _getShapeForEmotion(),
    );
  }

  double _getVelocityForEmotion() {
    switch (widget.emotion) {
      case 'sadness': return 0.006; // Быстрее дождь (было 0.003)
      case 'anger': return 0.015; // Очень быстрые искры (было 0.008)
      case 'joy': return -0.005; // Быстрее всплытие (было -0.002)
      case 'love': return 0.004; // Быстрее лепестки (было 0.002)
      case 'fear': return 0.002; // Чуть быстрее туман (было 0.001)
      default: return 0.006;
    }
  }

  ParticleShape _getShapeForEmotion() {
    switch (widget.emotion) {
      case 'joy': return ParticleShape.circle; // sparkles
      case 'sadness': return ParticleShape.raindrop; // rain
      case 'anger': return ParticleShape.spark; // lightning sparks
      case 'love': return ParticleShape.heart; // hearts
      case 'fear': return ParticleShape.circle; // fog
      case 'surprise': return ParticleShape.star; // stars
      default: return ParticleShape.circle;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles();
        return CustomPaint(
          painter: _ParticlePainter(_particles, widget.emotion),
          child: Container(),
        );
      },
    );
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.y += particle.velocityY;
      particle.x += particle.velocityX;
      particle.rotation += particle.rotationSpeed;

      // Респаун частиц
      if (particle.y > 1.0 || particle.y < -0.1) {
        particle.y = particle.velocityY > 0 ? -0.05 : 1.05;
        particle.x = _random.nextDouble();
      }

      if (particle.x > 1.0 || particle.x < 0.0) {
        particle.x = particle.x > 1.0 ? 0.0 : 1.0;
      }
    }
  }
}

class Particle {
  double x;
  double y;
  double velocityY;
  double velocityX;
  double size;
  double opacity;
  double rotation;
  double rotationSpeed;
  ParticleShape shape;

  Particle({
    required this.x,
    required this.y,
    required this.velocityY,
    required this.velocityX,
    required this.size,
    required this.opacity,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

enum ParticleShape {
  circle,
  raindrop,
  spark,
  heart,
  star,
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final String emotion;

  _ParticlePainter(this.particles, this.emotion);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = _getParticleColor().withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final pos = Offset(particle.x * size.width, particle.y * size.height);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, particle.size, paint);
          break;

        case ParticleShape.raindrop:
          _drawRaindrop(canvas, particle.size, paint);
          break;

        case ParticleShape.spark:
          _drawSpark(canvas, particle.size, paint);
          break;

        case ParticleShape.heart:
          _drawHeart(canvas, particle.size, paint);
          break;

        case ParticleShape.star:
          _drawStar(canvas, particle.size, paint);
          break;
      }

      canvas.restore();
    }
  }

  Color _getParticleColor() {
    // Используем насыщенные цвета с высокой opacity для яркости
    final baseColor = EmotionColors.getColor(emotion);
    final opacity = emotion == 'fear' ? 0.5 : 0.85; // Fear темнее, остальные ярче
    return baseColor.withOpacity(opacity);
  }

  void _drawRaindrop(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size)
      ..quadraticBezierTo(size, 0, 0, size * 2)
      ..quadraticBezierTo(-size, 0, 0, -size);
    canvas.drawPath(path, paint);
  }

  void _drawSpark(Canvas canvas, double size, Paint paint) {
    final path = Path()
      ..moveTo(0, -size * 2)
      ..lineTo(size * 0.3, 0)
      ..lineTo(0, size * 2)
      ..lineTo(-size * 0.3, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, double size, Paint paint) {
    final path = Path();
    path.moveTo(0, size * 0.5);
    path.cubicTo(-size, -size * 0.5, -size * 1.5, size * 0.5, 0, size * 1.5);
    path.cubicTo(size * 1.5, size * 0.5, size, -size * 0.5, 0, size * 0.5);
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (pi * 2 / 5) * i - pi / 2;
      final radius = i % 2 == 0 ? size : size * 0.5;
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}
