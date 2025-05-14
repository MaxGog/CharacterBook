import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode;
  final Box _box;

  ThemeProvider(this._box) : _themeMode = _readThemeMode(_box);

  ThemeMode get themeMode => _themeMode;

  static ThemeMode _readThemeMode(Box box) {
    try {
      return ThemeMode.values[box.get('themeMode', defaultValue: ThemeMode.system.index)];
    } catch (e) {
      return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _box.put('themeMode', mode.index);
    notifyListeners();
  }
}