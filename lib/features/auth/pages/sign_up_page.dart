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
  bool _isSocialLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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

    final error = await AuthService.signUpWithEmail(
      fullName: name,
      email: email,
      password: password,
      context: context,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _error = error);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _handleSocialSignUp(OAuthProvider provider) async {
    setState(() {
      _isSocialLoading = true;
      _error = null;
    });

    final error = await AuthService.socialSignUp(
      provider: provider,
      context: context,
      onSuccess: () {
        if (context.mounted) {
          context.go('/login');
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isSocialLoading = false;
      if (error != null) _error = error;
    });
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
              "Create Account",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Join us and start your job search today!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
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
              isLoading: _isLoading,
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

            _isSocialLoading
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
