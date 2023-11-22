import 'package:flutter/material.dart';

class PurpleBlueGradientColor {
  static const Color startColor = Color(0xFF6A1B9A); // Purple color
  static const Color endColor = Color(0xFF2196F3);
  static const Color white = Colors.white; // Blue color

  static LinearGradient get gradient {
    return const LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }
}
