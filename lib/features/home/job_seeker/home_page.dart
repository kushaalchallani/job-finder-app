// lib/features/auth/pages/home/job_seeker/home_page_refactored.dart
// ignore_for_file: deprecated_member_use, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/home/home.dart';
import 'package:job_finder_app/models/job_opening.dart';

class HomeScreen extends ConsumerWidget {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularJobsAsync = ref.watch(popularJobsProvider);
    final statsAsync = ref.watch(jobStatsProvider);
    final _ = ref.watch(testProvider);
    final _ = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Force invalidate all providers
            ref.invalidate(popularJobsProvider);
            ref.invalidate(jobStatsProvider);
            ref.invalidate(userProfileProvider);
            ref.invalidate(recentApplicationsProvider);

            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildDynamicHeader(ref),
                ),
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _buildDynamicStats(statsAsync),
                ),
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _buildDynamicApplications(ref),
                ),
                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: _buildDynamicJobs(popularJobsAsync),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicHeader(WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        final userName = userProfile?.fullName ?? 'User';
        final userRole = userProfile?.role ?? 'seeker';

        return Container(
          key: const ValueKey('header_data'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()},',
                      style: TextStyle(fontSize: 16, color: AppColors.grey600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (userRole == 'seeker') ...[
                      const SizedBox(height: 4),
                      Text(
                        'Job Seeker',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildNotificationButton(),
            ],
          ),
        );
      },
      loading: () => Container(
        key: const ValueKey('header_loading'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()},',
                  style: TextStyle(fontSize: 16, color: AppColors.grey600),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 120,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            _buildNotificationButton(),
          ],
        ),
      ),
      error: (_, __) => Container(
        key: const ValueKey('header_error'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()},',
                  style: TextStyle(fontSize: 16, color: AppColors.grey600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            _buildNotificationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.notifications_outlined, size: 24),
    );
  }

  Widget _buildDynamicStats(AsyncValue<Map<String, int>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Container(
        key: const ValueKey('stats_data'),
        child: QuickStats(stats: stats),
      ),
      loading: () => const QuickStatsLoading(key: ValueKey('stats_loading')),
      error: (_, __) => Container(
        key: const ValueKey('stats_error'),
        child: QuickStats(
          stats: {'totalJobs': 0, 'applications': 0, 'offers': 0},
        ),
      ),
    );
  }

  Widget _buildDynamicApplications(WidgetRef ref) {
    return Container(
      key: const ValueKey('applications'),
      child: const RecentApplications(),
    );
  }

  Widget _buildDynamicJobs(AsyncValue<List<JobOpening>> popularJobsAsync) {
    return popularJobsAsync.when(
      data: (jobs) => Container(
        key: const ValueKey('jobs_data'),
        child: PopularJobs(jobs: jobs),
      ),
      loading: () => const PopularJobsLoading(key: ValueKey('jobs_loading')),
      error: (error, __) =>
          PopularJobsError(key: const ValueKey('jobs_error'), error: error),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
