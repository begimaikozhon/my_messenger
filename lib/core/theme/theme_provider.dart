import 'package:flutter/material.dart';
import 'package:my_messenger/data/hive_boxes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    notifyListeners();
  }

  void _loadTheme() {
    final saved = HiveBoxes.settingsBox.get('themeMode', defaultValue: 'system');
    _themeMode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void _saveTheme() {
    HiveBoxes.settingsBox.put('themeMode', _themeMode.name);
  }
}
