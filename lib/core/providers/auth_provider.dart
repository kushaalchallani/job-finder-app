import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

// Global navigator key that can be used across the app
final globalNavigatorKey = GlobalKey<NavigatorState>();

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final authRedirectProvider = Provider<void>((ref) {
  void handleNavigation(
    BuildContext context,
    Session? session,
    AuthChangeEvent? event,
  ) {
    if (session != null) {
      final user = session.user;
      final metadata = user.userMetadata;

      if (metadata == null) {
        context.goNamed('home');
        return;
      }

      final role = metadata['role'] as String?;

      // Force navigation to appropriate home page based on role
      if (role == 'seeker') {
        context.goNamed('home');
      } else if (role == 'recruiter') {
        context.goNamed('recruiter-home');
      } else {
        context.goNamed('home');
      }
    } else {
      context.goNamed('login');
    }
  }

  ref.listen(authStateProvider, (previous, next) async {
    final data = next.valueOrNull;
    final session = data?.session;
    final event = data?.event;

    // Handle both sign in and sign out events
    if (event != AuthChangeEvent.signedIn &&
        event != AuthChangeEvent.signedOut) {
      return;
    }

    // Increased delay to ensure context is available
    Future.delayed(Duration(milliseconds: 500), () {
      final context = globalNavigatorKey.currentContext;

      if (context == null) {
        // Try again after a longer delay
        Future.delayed(Duration(milliseconds: 1000), () {
          final context2 = globalNavigatorKey.currentContext;
          if (context2 == null) {
            return;
          }
          handleNavigation(context2, session, event);
        });
        return;
      }

      handleNavigation(context, session, event);
    });
  });
});
