// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/flash_banner.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import '../../controllers/reset_password_controller.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(resetPasswordControllerProvider.notifier).clearError();
      _checkSession();
    });
  }

  void _checkSession() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(flashMessageQueueProvider)
            .enqueue(
              FlashMessage(
                text:
                    'Invalid or expired reset link. Please request a new one.',
                color: AppColors.error,
              ),
            );
        context.go('/login');
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    await ref
        .read(resetPasswordControllerProvider.notifier)
        .updatePassword(
          _passwordController.text,
          _confirmPasswordController.text,
        );

    final state = ref.read(resetPasswordControllerProvider);

    if (state.error != null) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: state.error!, color: AppColors.error));
    }

    if (state.successMessage != null && mounted) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text:
                  'Password updated successfully! Please sign in with your new password.',
              color: AppColors.success,
            ),
          );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.push('/forgot-password'),
                    icon: const Icon(Icons.arrow_back),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const Text(
                "Set new password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter your new password below. Make sure it's secure and easy to remember.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const FlashBanner(),
              const SizedBox(height: 32),

              AuthTextField(
                controller: _passwordController,
                label: "New Password",
                obscureText: true,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmPasswordController,
                label: "Confirm New Password",
                obscureText: true,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "Update Password",
                isLoading: state.isLoading,
                onPressed: _handlePasswordReset,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
