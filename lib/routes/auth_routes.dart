import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/auth/forgot_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/login_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/recruiter_sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/reset_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/sign_up_page.dart';

class AuthRoutes {
  static final routes = [
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
  ];
}
