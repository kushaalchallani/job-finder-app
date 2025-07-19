import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/services/auth_service.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/utils/shared_prefs.dart';

class LoginPage extends StatefulWidget {
  final String? errorMessage;
  const LoginPage({super.key, this.errorMessage});

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = GoRouterState.of(context);
      final extra = state.extra;
      if (extra != null && extra is Map && extra['error'] != null) {
        final errorMsg = extra['error'] as String;
        setState(() => _error = errorMsg);
      }

      final savedError = SharedPrefs.getString('loginError');
      if (savedError != null) {
        setState(() => _error = savedError);
        await SharedPrefs.remove('loginError');
      }

      final signupError = SharedPrefs.getString('signupError');
      if (signupError != null) {
        setState(() => _error = signupError);
        await SharedPrefs.remove('signupError');
      }
    });
  }

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

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
    });

    if (error == null) {
      context.go('/home');
    }
  }

  Future<void> _handleSocialSignIn(OAuthProvider provider) async {
    setState(() {
      _isSocialLoading = true;
      _error = null;
    });

    final error = await AuthService.signInWithSocial(
      provider: provider,
      context: context,
    );

    if (!mounted) return;

    setState(() {
      _isSocialLoading = false;
      _error = error;
    });

    if (error == null) {
      context.go('/home');
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
              const SizedBox(height: 18),
              const Text(
                "Welcome Back",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Sign in to continue your job hunt",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 18),

              if (_error != null)
                Container(
                  width: double.infinity,
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
