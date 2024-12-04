import 'package:flutter/material.dart';

import '../constants.dart';
import '../utils/api_pipeline.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> fetchDarkModeSetting() async {
    try {
      final responseData = await makeAPIRequest(
        url: Uri.parse(API_Endpoints.USER_DARKMODE.value),
        method: 'GET',
      );

      _isDarkMode = responseData['dark_mode'] ?? false;
      _updateThemeMode();
    } catch (e) {
      print("Error fetching dark mode setting: $e");
      _isDarkMode = false;
      _updateThemeMode();
    }
  }

  void _updateThemeMode() {
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(bool isDark) {
    _isDarkMode = isDark;
    _updateThemeMode();
  }
}
