// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      setState(() => _error = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await AuthService.signUp(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error == null) {
      context.go('/signin');
    } else {
      setState(() => _error = error);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Join us and start your job search today!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Name
            AuthTextField(controller: _nameController, label: "Full Name"),
            const SizedBox(height: 16),

            // Email
            AuthTextField(
              controller: _emailController,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Password
            AuthTextField(
              controller: _passwordController,
              label: "Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            AuthTextField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              obscureText: true,
            ),
            const SizedBox(height: 16),

            // Error Message
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            // Sign Up Button
            PrimaryButton(
              text: "Sign Up",
              isLoading: _isLoading,
              onPressed: _handleSignUp,
            ),
            const SizedBox(height: 24),

            // Divider
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

            // Social Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    await AuthService.socialSignUp(
                      provider: OAuthProvider.google,
                      onSuccess: () {
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    );
                  },
                  icon: Image.asset('assets/icons/google.png', height: 32),
                ),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: () async {
                    await AuthService.socialSignUp(
                      provider: OAuthProvider.facebook,
                      onSuccess: () {
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    );
                  },
                  icon: Image.asset('assets/icons/facebook.png', height: 32),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Already have an account?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: () => context.go('/signin'),
                  child: const Text("Sign In"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
