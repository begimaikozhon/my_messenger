import 'package:flutter/material.dart';

class NameUtils {
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  static Color getColorByName(String name) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.deepOrange,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
    ];

    // Берём код первой буквы в алфавите, чтобы стабильно генерировать цвет
    final code = name.codeUnitAt(0);
    return colors[code % colors.length];
  }
}
