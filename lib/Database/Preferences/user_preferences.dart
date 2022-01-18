//Switching themes in the flutter apps - Flutterant
//theme_preference.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const prefKey = "has-login";

  setUser(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences
        .setBool(prefKey, value)
        .then((value) => debugPrint(value.toString()));
  }

  Future<bool?> getUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(prefKey);
  }
}
//Switching themes in the flutter apps - Flutterant