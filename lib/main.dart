import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/secrets/supabase_secrets.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/routes/app_router.dart';
// ignore: depend_on_referenced_packages
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  await SharedPrefs.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleInitialLink();
    _handleIncomingLinks();
  }

  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        debugPrint('🔗 Initial deep link received: $initialUri');
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
          debugPrint('🔗 Incoming deep link received: $uri');
          await _processDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('⚠️ Error handling incoming links: $err');
      },
    );
  }

  Future<void> _processDeepLink(Uri uri) async {
    debugPrint('🔗 Processing deep link: $uri');
    debugPrint('🔗 URI path: ${uri.path}');
    debugPrint('🔗 URI query parameters: ${uri.queryParameters}');
    debugPrint('🔗 Full URI string: ${uri.toString()}');

    bool isPasswordReset =
        uri.queryParameters.containsKey('access_token') ||
        uri.queryParameters.containsKey('type') &&
            uri.queryParameters['type'] == 'recovery' ||
        uri.toString().contains('reset-password');

    bool isOAuth =
        (uri.queryParameters.containsKey('code') &&
            uri.queryParameters.containsKey('state')) ||
        uri.toString().contains('login-callback');

    if (isPasswordReset && mounted) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            AppRouter.router.go('/reset-password');
          }
        });
      } catch (e) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            AppRouter.router.go('/reset-password');
          }
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

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Job Finder',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
