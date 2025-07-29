// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
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
        redirectTo:
            'jobfinder://signup-callback', // �� CHANGED: Different URL for signup
      );

      final data = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('User cancelled or timed out.'),
      );

      final user = data.session?.user;
      if (user == null) return 'No user returned from OAuth signup.';

      final email = user.email;
      if (email == null) return 'Email not found from provider.';

      // 🔧 REMOVED: All validation logic moved to DeepLinkHandler
      // The deep link handler will handle the OAuth callback and show appropriate messages
      // 🔧 REMOVED: Don't sign out here - let the deep link handler handle it

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
        redirectTo: 'jobfinder://login-callback', // �� KEPT: Same URL for login
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

      // 🔧 REMOVED: All the validation logic is now handled in DeepLinkHandler
      // The deep link handler will process the OAuth callback and handle all error cases
      // 🔧 REMOVED: Don't sign out here - let the deep link handler handle it

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
