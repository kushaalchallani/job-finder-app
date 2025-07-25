import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/auth/forgot_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/recruiter_sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/reset_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/job_details.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/job_seeker_main.dart';
import 'package:job_finder_app/features/auth/pages/home/recruiter/create_job.dart';
import 'package:job_finder_app/features/auth/pages/home/recruiter/recruiter_main.dart';
import 'package:job_finder_app/features/auth/pages/home/recruiter/recruiter_dashboard.dart';
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
        builder: (context, state) => const JobSeekerMainScreen(),
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
        builder: (context, state) => const RecruiterMainScreen(),
      ),
      GoRoute(
        path: '/recruiter-dashboard',
        name: 'recruiter-dashboard',
        builder: (context, state) => const RecruiterDashboard(),
      ),
      GoRoute(
        path: '/create-job',
        name: 'create-job',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/job-details/:jobId',
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailsScreen(jobId: jobId);
        },
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
