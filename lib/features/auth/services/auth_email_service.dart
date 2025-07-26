import 'package:flutter/material.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthEmailService {
  static final _client = Supabase.instance.client;

  // signup with email
  static Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? company,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName, 'role': role},
      );

      final user = res.user;
      if (user == null) {
        return false;
      }

      final profileData = {
        'id': user.id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'sign_up_method': 'email',
      };
      if (company != null) {
        profileData['company'] = company;
      }

      await _client.from('profiles').insert(profileData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flashMessage', 'signup_success::/login');

      await _client.auth.signOut();
      return true;
    } catch (e) {
      debugPrint("Signup error: $e");
      return false;
    }
  }

  // Email + Password Sign In
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

  // Check reset password eligibility
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
              'Please confirm your email before resetting your password.',
        };
      } else {
        return {
          'exists': true,
          'canReset': false,
          'message': ErrorHandler.getAuthError(e.message),
        };
      }
    } catch (e) {
      return {
        'exists': false,
        'canReset': false,
        'message': 'An error occurred while checking your account.',
      };
    }
  }

  // Reset password backend trigger
  static Future<void> resetPassword({required String email}) async {
    final result = await checkPasswordResetEligibility(email: email);
    if (!result['canReset']) {
      throw Exception(result['message']);
    }
  }

  // Update password after reset
  static Future<void> updatePassword({required String newPassword}) async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        throw Exception('No active session. Try using the link again.');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flashMessage', 'password_reset_success::/login');
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(ErrorHandler.getAuthError(e.message));
    } catch (e) {
      throw Exception(ErrorHandler.getUserFriendlyError(e.toString()));
    }
  }
}
