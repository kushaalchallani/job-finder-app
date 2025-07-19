import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
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

      final existingEmailCheck = await _client
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingEmailCheck != null) {
        await _client.auth.signOut();
        await SharedPrefs.setString(
          'loginError',
          'An account with this email already exists. Please sign in instead.',
        );

        if (context != null && context.mounted) {
          context.go('/login');
        }

        return 'An account with this email already exists. Please sign in instead.';
      }

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
          'sign_up_method': provider.name,
        });
      }

      await _client.auth.signOut();
      onSuccess();
      return null;
    } on AuthException catch (e) {
      if (e.message.contains('code verifier')) {
        await _client.auth.signOut();
        return null;
      }
      if (e.message.contains('code verifier') ||
          e.message.contains('flow state') ||
          e.message.contains('flow_state_not_found')) {
        await _client.auth.signOut();
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
        context.go('/login');
      }

      if (context.mounted) {
        context.go('/home');
      }

      return null;
    } on TimeoutException {
      return ErrorHandler.getNetworkError("Login timed out. Try again.");
    } on AuthException catch (e) {
      if (e.message.contains('code verifier') ||
          e.message.contains('flow state') ||
          e.message.contains('flow_state_not_found')) {
        await _client.auth.signOut();
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
