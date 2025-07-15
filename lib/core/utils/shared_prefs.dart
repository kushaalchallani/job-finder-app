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

  // Optionally add other keys:
  static Future<void> clearPrefs() async {
    await _prefs.clear();
  }
}
