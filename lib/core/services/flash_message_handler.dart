import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';

/// Stores a flash message with a target route for redirection
Future<void> storeFlashMessage(
  String messageKey, {
  required String targetRoute,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final messageString = '$messageKey::$targetRoute';
  await prefs.setString('flashMessage', messageString);
  debugPrint('🔵 [FLASH] Stored message: $messageString');
}

/// Retrieves and removes the raw flash message string
Future<String?> getAndClearFlashMessage() async {
  final prefs = await SharedPreferences.getInstance();
  final msg = prefs.getString('flashMessage');
  if (msg != null) {
    await prefs.remove('flashMessage');
    debugPrint('🔵 [FLASH] Retrieved and cleared message: $msg');
  } else {
    debugPrint('🔵 [FLASH] No flash message found in prefs');
  }
  return msg;
}

/// Reads and handles flash message only if the current route matches
Future<void> handleFlashMessageFromPrefs(
  WidgetRef ref,
  String currentRoute,
) async {
  debugPrint('🔵 [FLASH] Checking for flash message on route: $currentRoute');

  final prefs = await SharedPreferences.getInstance();
  final rawFlash = prefs.getString('flashMessage');

  if (rawFlash == null) {
    debugPrint('🔵 [FLASH] No flash message found in prefs');
    return;
  }

  debugPrint('🔵 [FLASH] Found raw flash message: $rawFlash');

  final parts = rawFlash.split('::');
  if (parts.length != 2) {
    debugPrint('🔵 [FLASH] Invalid flash message format, removing: $rawFlash');
    await prefs.remove('flashMessage');
    return;
  }

  final messageKey = parts[0];
  final targetRoute = parts[1];

  debugPrint(
    '🔵 [FLASH] Parsed - Key: $messageKey, Target: $targetRoute, Current: $currentRoute',
  );

  // Only show flash if we're on the target route
  if (currentRoute != targetRoute) {
    debugPrint('🔵 [FLASH] Route mismatch, not showing message');
    return;
  }

  debugPrint('🔵 [FLASH] Route matches, processing message');

  final flashQueue = ref.read(flashMessageQueueProvider);

  final message = _resolveFlashMessage(messageKey);
  if (message != null) {
    debugPrint('🔵 [FLASH] Resolved message: ${message.text}');
    flashQueue.enqueue(message);
    debugPrint('🔵 [FLASH] Message enqueued successfully');
  } else {
    debugPrint('🔵 [FLASH] Failed to resolve message for key: $messageKey');
  }

  await prefs.remove('flashMessage');
  debugPrint('🔵 [FLASH] Flash message removed from prefs');
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
    default:
      return null;
  }
}
