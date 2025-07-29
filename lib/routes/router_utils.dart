import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class RouterUtils {
  static String? handleRedirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final location = state.matchedLocation;

    final publicRoutes = [
      '/login',
      '/signup',
      '/recruiter-signup',
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
      return isRecruiter ? '/recruiter-home' : '/home';
    }

    return null;
  }
}
