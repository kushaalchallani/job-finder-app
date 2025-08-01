import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/splash_page.dart';
import 'package:job_finder_app/routes/auth_routes.dart';
import 'package:job_finder_app/routes/job_seeker_routes.dart';
import 'package:job_finder_app/routes/recruiter_routes.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/',
    restorationScopeId: null, // Disable route restoration
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
    // Temporarily removed redirect to test auth provider
    // redirect: RouterUtils.handleRedirect,
  );
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);
