// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/services/flash_message_handler.dart';
import 'package:job_finder_app/core/widgets/flash_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/login_controller.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/utils/flash_message_queue.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.errorMessage});
  final String? errorMessage;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _handledFlash = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledFlash) {
      _handledFlash = true;
      Future.microtask(() {
        if (mounted) {
          handleFlashMessageFromPrefs(ref, '/login');
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    final success = await ref
        .read(loginControllerProvider.notifier)
        .signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (!success) {
      final error = ref.read(loginControllerProvider).error;
      if (error != null) {
        ref
            .read(flashMessageQueueProvider)
            .enqueue(FlashMessage(text: error, color: AppColors.error));
      }
    }
  }

  Future<void> _handleSocialSignIn(OAuthProvider provider) async {
    final success = await ref
        .read(loginControllerProvider.notifier)
        .signInWithSocial(provider: provider, context: context);

    if (!mounted) return;

    if (!success) {
      final error = ref.read(loginControllerProvider).error;
      if (error != null) {
        ref
            .read(flashMessageQueueProvider)
            .enqueue(FlashMessage(text: error, color: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const SizedBox(height: 18),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sign in to continue your job hunt",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),

              // ✅ Flash banner displays message from queue
              const FlashBanner(),

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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text("Forgot Password?"),
                ),
              ),
              PrimaryButton(
                text: "Log In",
                isLoading: state.isLoading,
                onPressed: _handleEmailSignIn,
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
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
                              _handleSocialSignIn(OAuthProvider.google),
                          icon: Image.asset(
                            'assets/icons/google.png',
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton(
                          onPressed: () =>
                              _handleSocialSignIn(OAuthProvider.facebook),
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
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () => context.push('/signup'),
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
