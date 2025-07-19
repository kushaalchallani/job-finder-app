import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordController() : super(const ForgotPasswordState());

  Future<void> sendResetLink(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
        error: 'Please enter your email address.',
        successMessage: null,
      );
      return;
    }
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await AuthService.resetPassword(email: email);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset link sent to your email!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

final forgotPasswordControllerProvider =
    StateNotifierProvider.autoDispose<
      ForgotPasswordController,
      ForgotPasswordState
    >((ref) => ForgotPasswordController());
