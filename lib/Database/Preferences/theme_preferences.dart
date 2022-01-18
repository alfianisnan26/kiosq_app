//Switching themes in the flutter apps - Flutterant
//theme_preference.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const prefKey = "theme-mode";

  setTheme(int value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(prefKey, value);
  }

  Future<int> getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(prefKey) ?? 0;
  }
}
//Switching themes in the flutter apps - Flutterant