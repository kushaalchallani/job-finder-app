import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/routes/app_router.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final BuildContext context;
  final WidgetRef ref;

  DeepLinkHandler(this.context, this.ref);

  void init() {
    _handleInitialLink();
    _handleIncomingLinks();
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  // MARK: - Initial Link Handling
  Future<void> _handleInitialLink() async {
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        await _processDeepLink(initialUri);
      }
    } catch (e) {
      _showError('Failed to process the link. Please try again.');
    }
  }

  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          await _processDeepLink(uri);
        }
      },
      onError: (err) {
        _showError('Failed to process the link. Please try again.');
      },
    );
  }

  // MARK: - Deep Link Processing
  Future<void> _processDeepLink(Uri uri) async {
    if (_isPasswordReset(uri)) {
      await _handlePasswordReset(uri);
    } else if (_isOAuth(uri)) {
      await _handleOAuth(uri);
    }
  }

  bool _isPasswordReset(Uri uri) {
    return uri.queryParameters.containsKey('access_token') ||
        (uri.queryParameters.containsKey('type') &&
            uri.queryParameters['type'] == 'recovery') ||
        uri.toString().contains('reset-password');
  }

  bool _isOAuth(Uri uri) {
    return (uri.queryParameters.containsKey('code') &&
            uri.queryParameters.containsKey('state')) ||
        uri.toString().contains('login-callback') ||
        uri.toString().contains('signup-callback');
  }

  // MARK: - Password Reset Handling
  Future<void> _handlePasswordReset(Uri uri) async {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('Failed to create session from reset link');
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.router.go('/reset-password');
      });
    } on AuthException catch (e) {
      _showError(_getAuthErrorMessage(e.message));
      _navigateToLogin();
    } catch (e) {
      _showError(
        'Invalid or expired password reset link. Please request a new one.',
      );
      _navigateToLogin();
    }
  }

  // MARK: - OAuth Handling
  Future<void> _handleOAuth(Uri uri) async {
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);

      final isSignup = uri.toString().contains('signup-callback');

      if (isSignup) {
        await _handleSocialSignupValidation();
      } else {
        await _handleSocialLoginValidation();
      }
    } on AuthException catch (e) {
      _showError(_getAuthErrorMessage(e.message));
      _navigateToLogin();
    } catch (e) {
      _showError('Failed to complete social authentication. Please try again.');
      _navigateToLogin();
    }
  }

  // MARK: - Social Login Validation
  Future<void> _handleSocialLoginValidation() async {
    try {
      final user = _getCurrentUser();
      final email = _getUserEmail(user);

      final existing = await _checkExistingProfile(email);
      if (existing == null) {
        await _signOutAndShowError('Account not found. Please sign up first.');
        return;
      }

      final signUpMethod = existing['sign_up_method'] as String?;
      final provider = _detectProvider(user);

      // Check if user has email account and trying to login with social
      if (signUpMethod == 'email') {
        await _signOutAndShowError(
          'This email is registered with email/password. Please login using your email and password.',
        );
        return;
      }

      if (signUpMethod != null && signUpMethod != provider) {
        await _signOutAndShowError(
          'Account exists with $signUpMethod. Please use $signUpMethod to login.',
        );
        return;
      }

      _showSuccess('Login successful!');
      _navigateToHome();
    } catch (e) {
      await _signOutAndShowError('Login failed. Please try again.');
    }
  }

  // MARK: - Social Signup Validation
  Future<void> _handleSocialSignupValidation() async {
    try {
      final user = _getCurrentUser();
      final email = _getUserEmail(user);

      final existing = await _checkExistingProfileForSignup(email);
      if (existing != null) {
        await _signOutAndShowError(
          'Account already exists. Please login instead.',
        );
        return;
      }

      await _createUserProfile(user, email);
      _showSuccess('Account created successfully! Please Login');
      await Supabase.instance.client.auth.signOut();
      _navigateToHome();
    } catch (e) {
      await _handleSignupError(e);
    }
  }

  // MARK: - Helper Methods
  User _getCurrentUser() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('No user returned from OAuth');
    }
    return user;
  }

  String _getUserEmail(User user) {
    final email = user.email;
    if (email == null) {
      throw Exception('OAuth provider did not return an email');
    }
    return email;
  }

  Future<Map<String, dynamic>?> _checkExistingProfile(String email) async {
    return await Supabase.instance.client
        .from('profiles')
        .select('sign_up_method')
        .eq('email', email)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> _checkExistingProfileForSignup(
    String email,
  ) async {
    return await Supabase.instance.client
        .from('profiles')
        .select('id')
        .eq('email', email)
        .maybeSingle();
  }

  String? _detectProvider(User user) {
    if (user.appMetadata.containsKey('provider') == true) {
      return user.appMetadata['provider'] as String;
    }

    if (user.userMetadata?.containsKey('provider') == true) {
      return user.userMetadata!['provider'] as String;
    }

    final email = user.email?.toLowerCase();
    if (email != null) {
      if (email.contains('google')) return 'google';
      if (email.contains('facebook')) return 'facebook';
    }

    return 'unknown';
  }

  Future<void> _createUserProfile(User user, String email) async {
    final provider = _detectProvider(user);

    final profileData = {
      'id': user.id,
      'email': email,
      'full_name':
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'] ??
          'Unknown',
      'sign_up_method': provider,
      'role': 'job_seeker',
    };

    if (Supabase.instance.client.auth.currentUser == null) {
      throw Exception('User not authenticated during profile creation');
    }

    await Supabase.instance.client.from('profiles').insert(profileData);
  }

  Future<void> _handleSignupError(dynamic error) async {
    final errorMessage = error.toString();

    if (errorMessage.contains('row-level security policy')) {
      _showError(
        'Profile creation failed due to security policy. Please contact support.',
      );
    } else if (errorMessage.contains('duplicate key')) {
      _showError('Account already exists. Please login instead.');
    } else {
      _showError('Signup failed. Please try again.');
    }

    await Supabase.instance.client.auth.signOut();
  }

  Future<void> _signOutAndShowError(String message) async {
    await Supabase.instance.client.auth.signOut();
    _showError(message);
  }

  // MARK: - UI Methods
  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: message, color: AppColors.error));
    });
  }

  void _showSuccess(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: message, color: AppColors.success));
    });
  }

  String _getAuthErrorMessage(String message) {
    if (message.contains('Email not confirmed')) {
      return 'Please confirm your email before proceeding.';
    } else if (message.contains('Invalid login credentials')) {
      return 'Invalid login credentials. Please try again.';
    } else if (message.contains('User not found')) {
      return 'No account found with this email address.';
    } else if (message.contains('Too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (message.contains('expired') || message.contains('invalid')) {
      return 'This link has expired or is invalid. Please request a new one.';
    } else {
      return 'An authentication error occurred. Please try again.';
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go('/login');
    });
  }

  void _navigateToHome() {
    // Navigation is handled by the auth state listener
  }
}
