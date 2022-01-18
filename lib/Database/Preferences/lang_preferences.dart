//Switching themes in the flutter apps - Flutterant
//theme_preference.dart
import 'package:shared_preferences/shared_preferences.dart';

class LangPreferences {
  static const prefKey = "key-languages";

  setLang(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(prefKey, value);
  }

  Future<String> getLang() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(prefKey) ?? "id_ID";
  }
}
//Switching themes in the flutter apps - Flutterant