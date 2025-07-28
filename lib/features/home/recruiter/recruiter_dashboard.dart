// lib/features/auth/pages/home/recruiter/recruiter_dashboard.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/dashboard/analytics_widgets.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/recent_applications_widget.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/dashboard/recruiter_dashboard_profile.dart';

class RecruiterDashboard extends ConsumerWidget {
  // ignore: use_super_parameters
  const RecruiterDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      context.push('/settings');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile Section
              userProfileAsync.when(
                data: (userProfile) =>
                    RecruiterDashboardProfile(userProfile: userProfile),
                loading: () =>
                    const RecruiterDashboardProfile(userProfile: null),
                error: (_, __) =>
                    const RecruiterDashboardProfile(userProfile: null),
              ),
              const SizedBox(height: 24),

              // Analytics Overview
              const AnalyticsOverview(),
              const SizedBox(height: 24),

              // Recent Applications
              const RecentApplicationsWidget(),
              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}
