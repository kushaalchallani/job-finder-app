import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

/// Stores a flash message with a target route for redirection
Future<void> storeFlashMessage(
  String messageKey, {
  required String targetRoute,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final messageString = '$messageKey::$targetRoute';
  await prefs.setString('flashMessage', messageString);
}

/// Retrieves and removes the raw flash message string
Future<String?> getAndClearFlashMessage() async {
  final prefs = await SharedPreferences.getInstance();
  final msg = prefs.getString('flashMessage');
  if (msg != null) {
    await prefs.remove('flashMessage');
  }
  return msg;
}

/// Reads and handles flash message only if the current route matches
Future<void> handleFlashMessageFromPrefs(
  WidgetRef ref,
  String currentRoute,
) async {
  final prefs = await SharedPreferences.getInstance();
  final rawFlash = prefs.getString('flashMessage');

  if (rawFlash == null) {
    return;
  }

  final parts = rawFlash.split('::');
  if (parts.length != 2) {
    await prefs.remove('flashMessage');
    return;
  }

  final messageKey = parts[0];
  final targetRoute = parts[1];

  // Only show flash if we're on the target route
  if (currentRoute != targetRoute) {
    return;
  }

  final flashQueue = ref.read(flashMessageQueueProvider);

  final message = _resolveFlashMessage(messageKey);
  if (message != null) {
    flashQueue.enqueue(message);
  }

  await prefs.remove('flashMessage');
}

/// Maps keys to actual FlashMessage objects
FlashMessage? _resolveFlashMessage(String key) {
  switch (key) {
    case 'signup_success':
      return FlashMessage(
        text: 'Signup successful! Please login to continue.',
        color: AppColors.success,
      );
    case 'password_reset_success':
      return FlashMessage(
        text: 'Password updated successfully. Please login.',
        color: AppColors.success,
      );
    case 'social_signup_email_exists':
      return FlashMessage(
        text:
            'An account with this email already exists. Please log in instead.',
        color: AppColors.error,
      );
    case 'social_login_blocked_email_signup':
      return FlashMessage(
        text:
            'This email is registered with email/password. Please log in using those credentials.',
        color: AppColors.error,
      );
    case 'social_login_blocked_conflict':
      return FlashMessage(
        text:
            'This account was created using a different provider. Please use the correct login method.',
        color: AppColors.error,
      );
    case 'social_login_account_not_found':
      return FlashMessage(
        text: 'Account not found. Please sign up before logging in.',
        color: AppColors.error,
      );
    default:
      return null;
  }
}
