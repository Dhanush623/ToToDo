import 'package:flutter/material.dart';
import 'package:totodo/src/constants/constants.dart';
import 'package:totodo/src/helper/storage_helper.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  getTheme() async {
    String? selectedTheme = await getData(Constants.selectedTheme);
    if (selectedTheme == ThemeMode.dark.name) {
      return true;
    }
    return false;
  }
}
