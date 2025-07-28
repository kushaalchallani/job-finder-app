import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/splash_page.dart';
import 'package:job_finder_app/routes/auth_routes.dart';
import 'package:job_finder_app/routes/job_seeker_routes.dart';
import 'package:job_finder_app/routes/recruiter_routes.dart';
import 'package:job_finder_app/routes/router_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      ...AuthRoutes.routes,
      ...JobSeekerRoutes.routes,
      ...RecruiterRoutes.routes,
    ],
    redirect: RouterUtils.handleRedirect,
  );
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);
