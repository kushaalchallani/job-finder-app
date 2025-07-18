import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// Sign up with email, password, and full name
  static Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required BuildContext context,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': fullName, // This sets metadata
        },
      );

      final user = res.user;
      if (user == null) {
        return 'Signup failed. User not created.';
      }

      // Insert into 'profiles' table
      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
      });

      // Immediately sign the user out after signup
      await _client.auth.signOut();

      if (context.mounted) {
        context.go('/login'); // Redirect to login page manually
      }

      return null; // success
    } catch (e) {
      return e.toString(); // return error message
    }
  }

  /// Social Sign Up
  static Future<String?> socialSignUp({
    required OAuthProvider provider,
    required VoidCallback onSuccess,
  }) async {
    late final StreamSubscription<AuthState> subscription;

    try {
      final completer = Completer<AuthState>();

      subscription = _client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && !completer.isCompleted) {
          completer.complete(data);
        }
      });

      await _client.auth.signInWithOAuth(
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
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        await _client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'full_name':
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              'User',
        });
      }

      await _client.auth.signOut();
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

  // Social Sign In
  static Future<String?> signInWithSocial({
    required OAuthProvider provider,
    required BuildContext context,
  }) async {
    late final StreamSubscription<AuthState> subscription;

    final completer = Completer<AuthState>();

    subscription = _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !completer.isCompleted) {
        completer.complete(data);
      }
    });

    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'jobfinder://login-callback',
      );

      final data = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Login timed out'),
      );

      final user = data.session?.user;
      if (user == null) throw Exception("No user returned");

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await _client.auth.signOut();
        await SharedPrefs.setString(
          'loginError',
          'Please sign up before logging in.',
        );
        // ignore: use_build_context_synchronously
        context.go('/login'); // Go back to Splash to show error
      }

      if (context.mounted) {
        context.go('/home');
      }

      return null;
    } on TimeoutException {
      return "Login timed out. Try again.";
    } catch (e) {
      return "Social login failed: $e";
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

  static User? get currentUser => _client.auth.currentUser;
}
