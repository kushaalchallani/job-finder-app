// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/flash_banner.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/sign_up_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(signUpControllerProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ref.read(signUpControllerProvider.notifier).clearError();
      ref
          .read(signUpControllerProvider.notifier)
          .setError("Please fill out all fields.");
      _showError();
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ref.read(signUpControllerProvider.notifier).clearError();
      ref
          .read(signUpControllerProvider.notifier)
          .setError("Passwords do not match");
      _showError();
      return;
    }

    final success = await ref
        .read(signUpControllerProvider.notifier)
        .signUpWithEmail(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
          role: 'job_seeker',
        );

    if (success && mounted) {
      context.go('/login');
    } else {
      _showError();
    }
  }

  void _showError() {
    if (!mounted) return;
    final error = ref.read(signUpControllerProvider).error;
    if (error != null) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: error, color: AppColors.error));
    }
  }

  Future<void> _handleSocialSignUp(OAuthProvider provider) async {
    await ref
        .read(signUpControllerProvider.notifier)
        .socialSignUp(
          provider: provider,
          context: context,
          onSuccess: () async {
            if (!mounted) return;
            context.go('/login');
          },
        );
    if (!mounted) return;

    final error = ref.read(signUpControllerProvider).error;
    if (error != null && mounted) {
      ref
          .read(flashMessageQueueProvider)
          .enqueue(FlashMessage(text: error, color: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: GestureDetector(
                onTap: () => context.push('/recruiter-signup'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Recruiter? Create your account →",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Join us and start your job search today!",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),

            const FlashBanner(),

            AuthTextField(controller: _nameController, label: "Full Name"),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _emailController,
              label: "Email",
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
              isLoading: state.isLoading,
              onPressed: _handleSignUp,
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("or continue with"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 10),

            state.isSocialLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _handleSocialSignUp(OAuthProvider.google),
                        icon: Image.asset(
                          'assets/icons/google.png',
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () =>
                            _handleSocialSignUp(OAuthProvider.facebook),
                        icon: Image.asset(
                          'assets/icons/facebook.png',
                          height: 32,
                        ),
                      ),
                    ],
                  ),
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
