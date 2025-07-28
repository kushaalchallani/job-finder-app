import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/secrets/supabase_secrets.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/routes/app_router.dart';
// ignore: depend_on_referenced_packages
import 'package:app_links/app_links.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';
import 'package:job_finder_app/core/services/deep_link_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );

  final appLinks = AppLinks();
  final initialUri = await appLinks.getInitialAppLink();

  if (initialUri != null && initialUri.queryParameters.containsKey('code')) {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
    } catch (e) {
      await AuthService.clearOAuthState();
    }
  } else {
    await AuthService.clearOAuthState();
  }

  await SharedPrefs.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  DeepLinkHandler? _deepLinkHandler;

  @override
  void initState() {
    super.initState();
    _deepLinkHandler = DeepLinkHandler(context);
    _deepLinkHandler!.init();
  }

  @override
  void dispose() {
    _deepLinkHandler?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authRedirectProvider);

    return MaterialApp.router(
      title: 'Job Finder',
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
