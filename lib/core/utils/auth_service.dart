import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// Sign up with email, password, and full name
  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) return "Sign up failed. Please try again.";

      // Insert into profiles table
      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': name,
        'email': email,
      });

      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error occurred. Please try again.";
    }
  }

  static Future<String?> socialSignUp({
    required OAuthProvider provider,
    required Function onSuccess,
  }) async {
    try {
      // Start OAuth Flow
      await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: 'jobfinder://login-callback',
      );

      // Wait briefly to let session settle
      await Future.delayed(const Duration(seconds: 2));

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return "Signup failed. No user returned.";

      // Check if profile already exists
      final existingProfile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'full_name':
              user.userMetadata?['name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'User',
        });
      }

      // ✅ Sign out after signup
      await Supabase.instance.client.auth.signOut();

      // Navigate back to login or whatever
      onSuccess();

      return null;
    } catch (e) {
      return "Signup failed: $e";
    }
  }

  static Future<void> startFacebookSignup() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: 'jobfinder://login-callback',
    );
  }

  /// Sign in
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return "Sign in failed.";
      }

      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Unexpected error occurred.";
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Current user
  static User? get currentUser => _client.auth.currentUser;
}
