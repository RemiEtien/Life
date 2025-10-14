import 'package:flutter/material.dart';
import 'emotion_effect_painter.dart';

/// Виджет для отображения продвинутых эффектов эмоций
class AdvancedEmotionEffect extends StatefulWidget {
  final String emotion;
  final double intensity;

  const AdvancedEmotionEffect({
    super.key,
    required this.emotion,
    this.intensity = 1.0,
  });

  @override
  State<AdvancedEmotionEffect> createState() => _AdvancedEmotionEffectState();
}

class _AdvancedEmotionEffectState extends State<AdvancedEmotionEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
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
        return CustomPaint(
          painter: EmotionEffectFactory.createPainter(
            emotion: widget.emotion,
            progress: _controller.value,
            intensity: widget.intensity,
            screenSize: MediaQuery.of(context).size,
          ),
          child: Container(),
        );
      },
    );
  }
}
