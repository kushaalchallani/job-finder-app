import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final authRedirectProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) async {
    final data = next.valueOrNull;
    final session = data?.session;

    // Delay to ensure context is available
    Future.delayed(Duration(milliseconds: 100), () {
      final context = navigatorKey.currentContext;

      if (context == null) {
        return;
      }

      if (session != null) {
        final user = session.user;
        final metadata = user.userMetadata;

        if (metadata == null) {
          context.go('/home'); // fallback
          return;
        }

        final role = metadata['role'] as String?;

        if (role == 'seeker') {
          context.go('/seeker/home');
        } else if (role == 'recruiter') {
          context.go('/recruiter/home');
        } else {
          context.go('/home');
        }
      } else {
        context.go('/login');
      }
    });
  });
});
