// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSocialService {
  static final _client = Supabase.instance.client;

  /// Social Sign Up
  static Future<String?> socialSignUp({
    required OAuthProvider provider,
    required VoidCallback onSuccess,
    BuildContext? context,
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

      final existingUserWithEmail = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (existingUserWithEmail != null) {
        await _client.auth.signOut();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('flashMessage', 'social_signup_email_exists');

        if (context != null && context.mounted) {
          context.go(
            '/login',
          ); // 🔁 Redirect to login page where flash message will be read
        }

        return 'An account with this email already exists. Please log in instead.';
      }

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await _client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'full_name':
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              'User',
          'sign_up_method': provider.name,
          'role': 'job_seeker',
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flashMessage', 'signup_success');

      await _client.auth.signOut();
      onSuccess();
      return null;
    } on AuthException catch (e) {
      await _client.auth.signOut();
      if (e.message.contains('code verifier') ||
          e.message.contains('flow state') ||
          e.message.contains('flow_state_not_found')) {
        return ErrorHandler.getUserFriendlyError(
          'OAuth session expired. Please try again.',
        );
      }
      return ErrorHandler.getUserFriendlyError('OAuth failed: ${e.message}');
    } catch (e) {
      return ErrorHandler.getUserFriendlyError('Social signup failed: $e');
    } finally {
      await subscription.cancel();
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

      final email = user.email;
      if (email == null) {
        throw Exception("OAuth provider did not return an email");
      }

      // 🔒 Check if the email exists in profiles
      final existing = await _client
          .from('profiles')
          .select('sign_up_method')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        final existingMethod = (existing['sign_up_method'] as String?)
            ?.toLowerCase();
        final currentMethod = provider.name.toLowerCase();

        if (existingMethod == 'email' && currentMethod != 'email') {
          await _client.auth.signOut();

          if (context.mounted) {
            await SharedPrefs.setString(
              'loginError',
              'This email is registered with email/password. Please log in using those credentials.',
            );
            context.go('/login');
          }

          return 'This email is registered with email/password. Please log in using those credentials.';
        }

        if (existingMethod != currentMethod) {
          await _client.auth.signOut();

          if (context.mounted) {
            await SharedPrefs.setString(
              'loginError',
              'This account was registered using a different provider ($existingMethod). Please log in accordingly.',
            );
            context.go('/login');
          }

          return 'This account was registered using a different provider ($existingMethod). Please log in accordingly.';
        }
      }

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await _client.auth.signOut();

        if (context.mounted) {
          await SharedPrefs.setString(
            'loginError',
            'Please sign up before logging in.',
          );
          context.go('/login');
        }

        return 'Please sign up before logging in.';
      }

      if (context.mounted) {
        context.go('/home');
      }

      return null;
    } on TimeoutException {
      return ErrorHandler.getNetworkError("Login timed out. Try again.");
    } on AuthException catch (e) {
      await _client.auth.signOut();
      if (e.message.contains('code verifier') ||
          e.message.contains('flow state') ||
          e.message.contains('flow_state_not_found')) {
        return ErrorHandler.getUserFriendlyError(
          'OAuth session expired. Please try again.',
        );
      }
      return ErrorHandler.getUserFriendlyError('OAuth failed: ${e.message}');
    } catch (e) {
      return ErrorHandler.getUserFriendlyError("Social login failed: $e");
    } finally {
      await subscription.cancel();
    }
  }
}
