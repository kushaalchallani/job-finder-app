import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/utils/auth_service.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSocialLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await AuthService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _error = error;
      } else {
        context.go('/home');
      }
    });
  }

  Future<void> _handleSocialSignIn(OAuthProvider provider) async {
    setState(() {
      _isSocialLoading = true;
      _error = null;
    });

    try {
      final error = await AuthService.signInWithSocial(
        provider: provider,
        onSuccess: () {
          if (mounted) {
            context.go('/home');
          }
        },
      );

      if (!mounted) return;

      if (error != null) {
        setState(() => _error = error);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Social login was cancelled or failed.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSocialLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const SizedBox(height: 32),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sign in to continue your job hunt",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
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
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              PrimaryButton(
                text: "Sign In",
                isLoading: _isLoading,
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
              _isSocialLoading
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
              const SizedBox(height: 24),
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
