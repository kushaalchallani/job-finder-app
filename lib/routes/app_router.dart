// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/sign_up_page.dart';
// import '../features/home/pages/home_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      //Testing
      // GoRoute(
      //   path: '/signin',
      //   name: 'signin',
      //   builder: (context, state) => const SignInPage(),
      // ),
      // GoRoute(
      //   path: '/signup',
      //   name: 'signup',
      //   builder: (context, state) => const SignUpPage(),
      // ),
      // GoRoute(
      //   path: '/forgot-password',
      //   name: 'forgot-password',
      //   builder: (context, state) => const ForgotPasswordPage(),
      // ),
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, state) =>
      //       const HomePage(), // you can create this later
      // ),
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      // Example: force login if not signed in
      if (state.fullPath == '/home' && !isLoggedIn) {
        return '/signin';
      }
      return null;
    },
  );
}
