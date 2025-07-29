import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/routes/app_router.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final BuildContext context;
  final WidgetRef ref;

  DeepLinkHandler(this.context, this.ref);

  void init() {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        await _processDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint('⚠️ Error handling initial link: $e');
      _showError('Failed to process the link. Please try again.');
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          await _processDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('⚠️ Error handling incoming links: $err');
        _showError('Failed to process the link. Please try again.');
      },
    );
  }

  Future<void> _processDeepLink(Uri uri) async {
    bool isPasswordReset =
        uri.queryParameters.containsKey('access_token') ||
        (uri.queryParameters.containsKey('type') &&
            uri.queryParameters['type'] == 'recovery') ||
        uri.toString().contains('reset-password');

    bool isOAuth =
        (uri.queryParameters.containsKey('code') &&
            uri.queryParameters.containsKey('state')) ||
        uri.toString().contains('login-callback');

    if (isPasswordReset) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);

        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          throw Exception('Failed to create session from reset link');
        }

        // Navigate to reset password page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/reset-password');
        });
      } on AuthException catch (e) {
        debugPrint('⚠️ Auth error in password reset: ${e.message}');
        _showError(_getAuthErrorMessage(e.message));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/login');
        });
      } catch (e) {
        debugPrint('⚠️ Error processing password reset link: $e');
        _showError(
          'Invalid or expired password reset link. Please request a new one.',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/login');
        });
      }
      return;
    }

    if (isOAuth) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } on AuthException catch (e) {
        debugPrint('⚠️ OAuth error: ${e.message}');
        _showError(_getAuthErrorMessage(e.message));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/login');
        });
      } catch (e) {
        debugPrint('⚠️ OAuth processing error: $e');
        _showError('Failed to complete social login. Please try again.');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/login');
        });
      }
      return;
    }
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: message, color: AppColors.error));
    });
  }

  String _getAuthErrorMessage(String message) {
    if (message.contains('Email not confirmed')) {
      return 'Please confirm your email before proceeding.';
    } else if (message.contains('Invalid login credentials')) {
      return 'Invalid login credentials. Please try again.';
    } else if (message.contains('User not found')) {
      return 'No account found with this email address.';
    } else if (message.contains('Too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (message.contains('expired') || message.contains('invalid')) {
      return 'This link has expired or is invalid. Please request a new one.';
    } else {
      return 'An authentication error occurred. Please try again.';
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
