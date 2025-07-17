import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final authRedirectProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) {
    final data = next.valueOrNull;
    final session = data?.session;
    final context = navigatorKey.currentContext;

    if (context == null) return;

    if (session != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  });
});
