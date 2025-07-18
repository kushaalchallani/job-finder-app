import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Social Sign Up
  static Future<String?> socialSignUp({
    required OAuthProvider provider,
    required VoidCallback onSuccess,
  }) async {
    final supabase = Supabase.instance.client;
    late final StreamSubscription<AuthState> subscription;

    try {
      final completer = Completer<AuthState>();

      subscription = supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && !completer.isCompleted) {
          completer.complete(data);
        }
      });

      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'jobfinder://login-callback',
      );

      final data = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('User cancelled or timed out.'),
      );

      final user = data.session?.user;
      if (user == null) return 'No user returned from OAuth signup.';

      final email = user.email;
      if (email == null) return 'Email not found from provider.';

      // Check if profile already exists
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'full_name':
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              'User',
        });
      }

      await supabase.auth.signOut();
      onSuccess();
      return null;
    } on TimeoutException {
      return 'Login cancelled or timed out.';
    } on AuthException catch (e) {
      if (e.message.contains('code verifier')) {
        return 'OAuth failed — app may have been hot reloaded. Please restart and try again.';
      }
      return 'OAuth failed: ${e.message}';
    } catch (e) {
      return 'Social signup failed: $e';
    } finally {
      await subscription.cancel();
    }
  }

  /// Email + Password Sign In
  static Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) return "Sign in failed. Try again.";
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return "Unexpected error. Please try again.";
    }
  }

  /// Social Sign In
  static Future<String?> signInWithSocial({
    required OAuthProvider provider,
    required VoidCallback onSuccess,
  }) async {
    final supabase = Supabase.instance.client;
    late final StreamSubscription<AuthState> subscription;

    try {
      final completer = Completer<AuthState>();

      subscription = supabase.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && !completer.isCompleted) {
          completer.complete(data);
        }
      });

      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'jobfinder://login-callback',
      );

      final data = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('User cancelled or timed out.'),
      );

      if (data.session?.user == null) return 'Social sign-in failed.';

      onSuccess();
      return null;
    } on TimeoutException {
      return 'Login cancelled or timed out.';
    } catch (e) {
      return 'Social sign-in failed: $e';
    } finally {
      await subscription.cancel();
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('hasOpenedBefore');
  }

  /// Current user getter
  static User? get currentUser => _client.auth.currentUser;
}
