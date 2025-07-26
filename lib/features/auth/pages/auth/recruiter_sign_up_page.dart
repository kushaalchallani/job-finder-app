import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/widgets/flash_banner.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';
import 'package:job_finder_app/features/auth/services/auth_email_service.dart';

class RecruiterSignUpPage extends ConsumerStatefulWidget {
  const RecruiterSignUpPage({super.key});

  @override
  ConsumerState<RecruiterSignUpPage> createState() =>
      _RecruiterSignUpPageState();
}

class _RecruiterSignUpPageState extends ConsumerState<RecruiterSignUpPage> {
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final company = _companyController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty ||
        company.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text: "Please fill out all fields.",
              color: AppColors.error,
            ),
          );
      return;
    }

    if (password != confirm) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text: "Passwords do not match.",
              color: AppColors.error,
            ),
          );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await AuthEmailService.signUpWithEmail(
      email: email,
      password: password,
      fullName: company,
      role: 'recruiter',
      company: company,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      context.go('/login');
    } else {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(
            FlashMessage(
              text: "Sign up failed. Please try again later.",
              color: AppColors.error,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 18),
            const Text(
              "Create Recruiter Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Start hiring the right talent for your company.",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            const FlashBanner(),

            AuthTextField(
              controller: _companyController,
              label: "Company Name",
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: "Work Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _passwordController,
              label: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),

            PrimaryButton(
              text: "Sign Up",
              isLoading: _isLoading,
              onPressed: _handleSignUp,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
