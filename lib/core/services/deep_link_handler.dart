import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/routes/app_router.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final BuildContext context;

  DeepLinkHandler(this.context);

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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/reset-password');
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go('/reset-password');
        });
      }
      return;
    }

    if (isOAuth) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (e) {
        // Handle OAuth error silently
      }
      return;
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
