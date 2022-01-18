//theme_model.dart
import 'package:flutter/material.dart';
import 'package:kiosq_app/Database/Preferences/theme_preferences.dart';

class ThemeModel extends ChangeNotifier {
  late int _mode;
  late ThemePreferences _preferences;

  ThemeMode get mode {
    switch (_mode) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeModel() {
    _mode = 0;
    _preferences = ThemePreferences();
    getPreferences();
  }

//Switching themes in the flutter apps - Flutterant
  set modeInt(int value) {
    _mode = value;
    notifyListeners();
  }

  int get modeInt => _mode;

  getPreferences() async {
    _mode = await _preferences.getTheme();
    notifyListeners();
  }
}
//Switching themes in the flutter apps - Flutterant
