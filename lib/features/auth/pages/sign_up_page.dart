// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/sign_up_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

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
    Future.microtask(
      () => ref.read(signUpControllerProvider.notifier).clearError(),
    );
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
    if (_passwordController.text != _confirmPasswordController.text) {
      ref.read(signUpControllerProvider.notifier).clearError();
      ref
          .read(signUpControllerProvider.notifier)
          .setError("Passwords do not match");
      return;
    }
    await ref
        .read(signUpControllerProvider.notifier)
        .signUpWithEmail(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          context: context,
        );
  }

  Future<void> _handleSocialSignUp(OAuthProvider provider) async {
    await ref
        .read(signUpControllerProvider.notifier)
        .socialSignUp(
          provider: provider,
          context: context,
          onSuccess: () {
            if (context.mounted) {
              context.go('/login');
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 18),
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Join us and start your job search today!",
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            if (state.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
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
            const SizedBox(height: 24),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
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
