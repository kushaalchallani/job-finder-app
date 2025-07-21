import 'package:flutter/material.dart';

class ErrorHandler {
  static String getUserFriendlyError(String error) {
    final lowerError = error.toLowerCase();

    debugPrint('DEBUG - Original error: $error');
    debugPrint('DEBUG - Lowercase error: $lowerError');

    // Email-related errors
    if (lowerError.contains('invalid email') ||
        lowerError.contains('email format') ||
        lowerError.contains('email is invalid')) {
      return 'Please enter a valid email address.';
    }
    if (lowerError.contains('email already registered') ||
        lowerError.contains('already been registered') ||
        lowerError.contains('email already exists') ||
        lowerError.contains('user already registered')) {
      return 'An account with this email already exists. Please sign in instead.';
    }

    // Password-related errors
    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    if (lowerError.contains('password') && lowerError.contains('short')) {
      return 'Password is too short. Please use at least 6 characters.';
    }
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid credentials') ||
        lowerError.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    if (lowerError.contains('no active session') ||
        lowerError.contains('reset link')) {
      return 'Your password reset link is invalid or has expired. Please request a new password reset email.';
    }

    if (lowerError.contains('password') && lowerError.contains('weak')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    if (lowerError.contains('password') && lowerError.contains('short')) {
      return 'Password is too short. Please use at least 6 characters.';
    }
    if (lowerError.contains('new password') &&
        lowerError.contains('old password')) {
      return 'New password must be different from the old password.';
    }
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid credentials') ||
        lowerError.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }

    // Network/connection errors
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout') ||
        lowerError.contains('unable to reach') ||
        lowerError.contains('connection refused') ||
        lowerError.contains('no internet')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (lowerError.contains('server error') ||
        lowerError.contains('500') ||
        lowerError.contains('502') ||
        lowerError.contains('503')) {
      return 'Server error. Please try again later.';
    }

    // OAuth errors
    if (lowerError.contains('oauth') ||
        lowerError.contains('social') ||
        lowerError.contains('google') ||
        lowerError.contains('facebook')) {
      return 'Social login failed. Please try again or use email signup.';
    }
    if (lowerError.contains('cancelled') ||
        lowerError.contains('timed out') ||
        lowerError.contains('timeout')) {
      return 'Login was cancelled or timed out. Please try again.';
    }
    if (lowerError.contains('code verifier') ||
        lowerError.contains('verifier')) {
      return 'Social login failed. Please restart the app and try again.';
    }

    // Database errors
    if (lowerError.contains('duplicate key') ||
        lowerError.contains('unique constraint') ||
        lowerError.contains('already exists')) {
      return 'This information is already in use. Please try different details.';
    }
    if (lowerError.contains('foreign key') ||
        lowerError.contains('constraint') ||
        lowerError.contains('database')) {
      return 'Unable to process request. Please try again.';
    }

    // Supabase specific errors
    if (lowerError.contains('supabase')) {
      return 'Service error. Please try again later.';
    }
    if (lowerError.contains('auth') && lowerError.contains('failed')) {
      return 'Authentication failed. Please try again.';
    }
    if (lowerError.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (lowerError.contains('too many requests') ||
        lowerError.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lowerError.contains('supabase')) {
      return 'Service error. Please try again later.';
    }
    if (lowerError.contains('auth') && lowerError.contains('failed')) {
      return 'Authentication failed. Please try again.';
    }
    if (lowerError.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (lowerError.contains('too many requests') ||
        lowerError.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // Generic errors
    if (lowerError.contains('unexpected error') ||
        lowerError.contains('internal error') ||
        lowerError.contains('something went wrong')) {
      return 'Something went wrong. Please try again.';
    }
    if (lowerError.contains('signup failed') ||
        lowerError.contains('sign in failed') ||
        lowerError.contains('signup error')) {
      return 'Unable to create account. Please try again.';
    }
    if (lowerError.contains('authentication failed') ||
        lowerError.contains('auth failed')) {
      return 'Authentication failed. Please try again.';
    }

    // If no specific match, return a generic message
    return 'Something went wrong. Please try again.';
  }

  /// Handle specific authentication errors
  static String getAuthError(String error) {
    final lowerError = error.toLowerCase();

    // Common Supabase auth errors
    if (lowerError.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (lowerError.contains('email not confirmed')) {
      return 'Please check your email and confirm your account.';
    }
    if (lowerError.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (lowerError.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (lowerError.contains('weak password')) {
      return 'Password is too weak. Please choose a stronger password.';
    }

    return getUserFriendlyError(error);
  }

  /// Handle network-specific errors
  static String getNetworkError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('no internet') ||
        lowerError.contains('no connection')) {
      return 'No internet connection. Please check your network and try again.';
    }
    if (lowerError.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (lowerError.contains('server down') ||
        lowerError.contains('service unavailable')) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    return getUserFriendlyError(error);
  }
}
