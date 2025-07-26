import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/auth/forgot_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/recruiter_sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/reset_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/home/home_page.dart';
import 'package:job_finder_app/features/auth/pages/home/recruiter_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/auth/login_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          errorMessage: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/recruiter-signup',
        name: 'recruiter-signup',
        builder: (context, state) => const RecruiterSignUpPage(),
      ),
      GoRoute(
        path: '/recruiter-home',
        name: 'recruiter-home',
        builder: (context, state) => const RecruiterHomePage(),
      ),
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      final publicRoutes = [
        '/login',
        '/signup',
        '/forgot-password',
        '/reset-password',
      ];

      if (!isLoggedIn) {
        return publicRoutes.contains(location) ? null : '/login';
      }

      final role = session.user.userMetadata?['role'] as String?;
      final isRecruiter = role == 'recruiter';

      if (location == '/home' && isRecruiter) return '/recruiter-home';
      if (location == '/recruiter-home' && !isRecruiter) return '/home';

      if (publicRoutes.contains(location)) {
        // prevent logged-in users from visiting login/signup again
        return isRecruiter ? '/recruiter-home' : '/home';
      }

      return null;
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);
