// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/shared_prefs.dart';
import 'package:job_finder_app/core/widgets/button.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isFirstLaunch = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _handleCheck();
  }

  Future<void> _handleCheck() async {
    final isFirst = !SharedPrefs.hasOpenedBefore;
    final user = Supabase.instance.client.auth.currentUser;

    if (isFirst) {
      setState(() {
        _isFirstLaunch = true;
        _isLoading = false;
      });
    } else {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      if (user != null) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    }
  }

  void _onGetStarted() async {
    await SharedPrefs.setOpened();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Center(
                  child: Image.asset('assets/images/logo.png', height: 600),
                ),
                Column(
                  children: [
                    if (_isFirstLaunch)
                      PrimaryButton(
                        text: "Get Started",
                        onPressed: _onGetStarted,
                      )
                    else if (_isLoading)
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),

                    const SizedBox(height: 20),

                    const Text(
                      "Powered by Job Finder",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
