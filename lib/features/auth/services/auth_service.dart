import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/features/auth/services/auth_email_service.dart';
import 'package:job_finder_app/features/auth/services/auth_social_service.dart';
import 'package:job_finder_app/features/auth/services/auth_utils.dart';

class AuthService {
  // Email/password
  static Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required BuildContext context,
  }) => AuthEmailService.signUpWithEmail(
    email: email,
    password: password,
    fullName: fullName,
    context: context,
  );

  static Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) => AuthEmailService.signInWithEmail(email: email, password: password);

  static Future<Map<String, dynamic>> checkPasswordResetEligibility({
    required String email,
  }) => AuthEmailService.checkPasswordResetEligibility(email: email);

  static Future<void> resetPassword({required String email}) =>
      AuthEmailService.resetPassword(email: email);

  static Future<void> updatePassword({required String newPassword}) =>
      AuthEmailService.updatePassword(newPassword: newPassword);

  // Social
  static Future<String?> socialSignUp({
    required OAuthProvider provider,
    required VoidCallback onSuccess,
    BuildContext? context,
  }) => AuthSocialService.socialSignUp(
    provider: provider,
    onSuccess: onSuccess,
    context: context,
  );

  static Future<String?> signInWithSocial({
    required OAuthProvider provider,
    required BuildContext context,
  }) =>
      AuthSocialService.signInWithSocial(provider: provider, context: context);

  // Utils
  static Future<void> clearOAuthState() => AuthUtils.clearOAuthState();
  static Future<void> signOut() => AuthUtils.signOut();
  static User? get currentUser => AuthUtils.currentUser;
}
