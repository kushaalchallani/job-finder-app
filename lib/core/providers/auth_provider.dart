import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final authRedirectProvider = Provider<void>((ref) {
  print('[authRedirectProvider] initialized ✅');

  ref.listen(authStateProvider, (previous, next) async {
    print('[authRedirectProvider] Auth state changed');

    final data = next.valueOrNull;
    final session = data?.session;

    // Delay to ensure context is available
    Future.delayed(Duration(milliseconds: 100), () {
      final context = navigatorKey.currentContext;

      if (context == null) {
        print('[authRedirectProvider] context is still null ❌');
        return;
      }

      if (session != null) {
        final user = session.user;
        final metadata = user.userMetadata;

        if (metadata == null) {
          print('[authRedirectProvider] No metadata found ❌');
          context.go('/home'); // fallback
          return;
        }

        final role = metadata['role'] as String?;
        print('[authRedirectProvider] role: $role');

        if (role == 'seeker') {
          context.go('/seeker/home');
        } else if (role == 'recruiter') {
          context.go('/recruiter/home');
        } else {
          context.go('/home');
        }
      } else {
        print('[authRedirectProvider] no session, going to login');
        context.go('/login');
      }
    });
  });
});
