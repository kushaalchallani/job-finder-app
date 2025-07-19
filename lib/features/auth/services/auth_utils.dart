import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static final _client = Supabase.instance.client;

  static Future<void> clearOAuthState() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      // ignore errors when clearing state
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasOpenedBefore');
  }

  static User? get currentUser => _client.auth.currentUser;
}
