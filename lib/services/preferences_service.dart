import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  const PreferencesService._(this._prefs);
  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    var prefs = await SharedPreferences.getInstance();
    return PreferencesService._(prefs);
  }

  ThemeMode getThemeMode() {
    var value = _prefs.getString('app_theme_mode');
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString('app_theme_mode', mode.name);
  }

  Future<void> saveValue(
    String templateName,
    String paramKey,
    Object? value,
  ) async {
    if (paramKey == 'projectTitle' || paramKey == 'projectPath') {
      return;
    }

    var key = '$templateName/$paramKey';

    if (value == null) {
      await _prefs.remove(key);
      return;
    }

    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else if (value is List) {
      await _prefs.setStringList(key, value.map((e) => e.toString()).toList());
    } else {
      await _prefs.setString(key, value.toString());
    }
  }

  dynamic getValue(String templateName, String paramKey) {
    if (paramKey == 'projectTitle' || paramKey == 'projectPath') {
      return null;
    }
    var key = '$templateName/$paramKey';
    return _prefs.get(key);
  }
}
