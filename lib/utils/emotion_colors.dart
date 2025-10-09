import 'package:flutter/material.dart';

/// Централизованные цвета эмоций - яркие и насыщенные
class EmotionColors {
  EmotionColors._(); // private constructor

  /// Получить цвет эмоции (насыщенный, яркий)
  static Color getColor(String? emotion) {
    if (emotion == null) return defaultColor;

    switch (emotion) {
      case 'joy':
        return joy;
      case 'sadness':
        return sadness;
      case 'anger':
        return anger;
      case 'fear':
        return fear;
      case 'disgust':
        return disgust;
      case 'surprise':
        return surprise;
      case 'love':
        return love;
      case 'pride':
        return pride;
      default:
        return defaultColor;
    }
  }

  // Яркие, насыщенные цвета эмоций
  static const Color joy = Color(0xFFFFD700);        // Золотой (вместо тусклого желтого)
  static const Color sadness = Color(0xFF1E88E5);    // Яркий синий (вместо блеклого)
  static const Color anger = Color(0xFFE53935);      // Насыщенный красный
  static const Color fear = Color(0xFF7B1FA2);       // Фиолетовый (вместо зеленого)
  static const Color disgust = Color(0xFF43A047);    // Насыщенный зеленый
  static const Color surprise = Color(0xFFFF6F00);   // Яркий оранжевый
  static const Color love = Color(0xFFEC407A);       // Яркий розовый
  static const Color pride = Color(0xFF8E24AA);      // Насыщенный пурпурный

  static const Color defaultColor = Color(0xFFFF6B6B); // Красный по умолчанию
}
