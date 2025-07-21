// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/flash_banner.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import '../controllers/forgot_password_controller.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(forgotPasswordControllerProvider.notifier).clearError(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    await ref
        .read(forgotPasswordControllerProvider.notifier)
        .sendResetLink(_emailController.text.trim());

    final state = ref.read(forgotPasswordControllerProvider);
    if (state.successMessage != null) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(text: state.successMessage!, color: AppColors.success),
          );
    } else if (state.error != null) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: state.error!, color: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FlashBanner(),

              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
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
              const SizedBox(height: 16),
              const Text(
                "Reset your password",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              AuthTextField(
                controller: _emailController,
                label: "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: "Send Reset Link",
                isLoading: state.isLoading,
                onPressed: _handleResetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
