import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

Future<void> handleFlashMessageFromPrefs(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final flash = prefs.getString('flashMessage');

  if (flash == null) return;

  switch (flash) {
    case 'signup_success':
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text: 'Signup successful! Please login to continue.',
              color: AppColors.success,
            ),
          );
      break;

    case 'password_reset_success':
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text: 'Password updated successfully. Please login.',
              color: AppColors.success,
            ),
          );
      break;

    case 'social_signup_email_exists':
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text:
                  'An account with this email already exists. Please log in instead.',
              color: AppColors.error,
            ),
          );
      break;

    case 'social_login_blocked_email_signup':
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text:
                  'This email is registered with email/password. Please log in using those credentials.',
              color: AppColors.error,
            ),
          );
      break;

    case 'social_login_blocked_conflict':
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text:
                  'This account was created using a different provider. Please use the correct login method.',
              color: AppColors.error,
            ),
          );
      break;
  }

  await prefs.remove('flashMessage');
}
