import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';

class ResetPasswordState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ResetPasswordState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ResetPasswordState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ResetPasswordController extends StateNotifier<ResetPasswordState> {
  ResetPasswordController() : super(const ResetPasswordState());

  Future<void> updatePassword(String password, String confirmPassword) async {
    if (password.isEmpty) {
      state = state.copyWith(
        error: 'Please enter a new password.',
        successMessage: null,
      );
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(
        error: 'Password must be at least 6 characters long.',
        successMessage: null,
      );
      return;
    }
    if (password != confirmPassword) {
      state = state.copyWith(
        error: 'Passwords do not match.',
        successMessage: null,
      );
      return;
    }
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await AuthService.updatePassword(newPassword: password);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password updated successfully!',
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

final resetPasswordControllerProvider =
    StateNotifierProvider.autoDispose<
      ResetPasswordController,
      ResetPasswordState
    >((ref) => ResetPasswordController());
