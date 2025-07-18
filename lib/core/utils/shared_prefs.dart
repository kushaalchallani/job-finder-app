// ignore_for_file: depend_on_referenced_packages
import "package:shared_preferences/shared_preferences.dart";

class SharedPrefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get hasOpenedBefore => _prefs.getBool('hasOpenedBefore') ?? false;

  static Future<void> setOpened() async {
    await _prefs.setBool('hasOpenedBefore', true);
  }

  static Future<void> clearPrefs() async {
    await _prefs.clear();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
