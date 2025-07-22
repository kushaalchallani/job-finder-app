import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final recruiterSignupControllerProvider =
    StateNotifierProvider<RecruiterSignupController, RecruiterSignupState>(
      (ref) => RecruiterSignupController(),
    );

class RecruiterSignupController extends StateNotifier<RecruiterSignupState> {
  RecruiterSignupController() : super(RecruiterSignupState());

  final _client = Supabase.instance.client;

  Future<bool> signUpRecruiter({
    required String company,
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: "Signup failed. Please try again.",
        );
        return false;
      }

      await _client.from('profiles').insert({
        'id': user.id,
        'email': email,
        'company': company,
        'role': 'recruiter',
      });

      // Flash success
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('flashMessage', 'signup_success');

      await _client.auth.signOut();

      state = state.copyWith(isLoading: false);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getAuthError(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.getUserFriendlyError("Signup failed: $e"),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class RecruiterSignupState {
  final bool isLoading;
  final String? error;

  RecruiterSignupState({this.isLoading = false, this.error});

  RecruiterSignupState copyWith({bool? isLoading, String? error}) {
    return RecruiterSignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
