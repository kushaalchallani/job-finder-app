import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/secrets/supabase_secrets.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';
import 'package:job_finder_app/core/utils/auth_service.dart';
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

  final appLinks = AppLinks();
  final initialUri = await appLinks.getInitialAppLink();

  if (initialUri != null && initialUri.queryParameters.containsKey('code')) {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(initialUri);
    } catch (e) {
      debugPrint('⚠️ Ignored OAuth redirect error: $e');
      await AuthService.clearOAuthState();
    }
  } else {
    await AuthService.clearOAuthState();
  }

  await SharedPrefs.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Job Finder',
      debugShowCheckedModeBanner: false,
      theme: AppColors.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
