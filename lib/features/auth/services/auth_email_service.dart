import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthEmailService {
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
        data: {'display_name': fullName},
      );

      final user = res.user;
      if (user == null) {
        return 'Signup failed. User not created.';
      }

      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'sign_up_method': 'email',
      });

      await _client.auth.signOut();

      if (context.mounted) {
        context.go('/login');
      }

      return null;
    } catch (e) {
      return ErrorHandler.getUserFriendlyError(e.toString());
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
      return ErrorHandler.getAuthError(e.message);
    } catch (_) {
      return ErrorHandler.getUserFriendlyError(
        "Unexpected error. Please try again.",
      );
    }
  }

  /// Check if user exists and can reset password (strict: only email signups)
  static Future<Map<String, dynamic>> checkPasswordResetEligibility({
    required String email,
  }) async {
    try {
      final profile = await _client
          .from('profiles')
          .select('sign_up_method')
          .eq('email', email)
          .maybeSingle();

      if (profile == null) {
        return {
          'exists': false,
          'canReset': false,
          'message': 'No account found with this email address.',
        };
      }

      if (profile['sign_up_method'] != 'email') {
        return {
          'exists': true,
          'canReset': false,
          'message':
              'Password reset is not available for this account. Please use your social login provider to sign in.',
        };
      }

      try {
        await _client.auth.resetPasswordForEmail(
          email,
          redirectTo: 'jobfinder://reset-password',
        );
        return {
          'exists': true,
          'canReset': true,
          'message': 'Password reset link sent to your email!',
        };
      } on AuthException catch (e) {
        if (e.message.contains('Email not confirmed')) {
          return {
            'exists': true,
            'canReset': false,
            'message':
                'Please confirm your email address before resetting your password.',
          };
        } else {
          return {
            'exists': true,
            'canReset': false,
            'message': ErrorHandler.getAuthError(e.message),
          };
        }
      }
    } catch (e) {
      return {
        'exists': false,
        'canReset': false,
        'message': 'An error occurred while checking your account.',
      };
    }
  }

  /// Reset password by sending reset email
  static Future<void> resetPassword({required String email}) async {
    final result = await checkPasswordResetEligibility(email: email);

    if (!result['canReset']) {
      throw Exception(result['message']);
    }
  }

  /// Update password after reset
  static Future<void> updatePassword({required String newPassword}) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        throw Exception(
          'No active session. Please click the reset link in your email again.',
        );
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));

      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(ErrorHandler.getAuthError(e.message));
    } catch (e) {
      throw Exception(ErrorHandler.getUserFriendlyError(e.toString()));
    }
  }
}
