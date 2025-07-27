// lib/features/auth/pages/home/job_seeker/home_page_refactored.dart
// ignore_for_file: deprecated_member_use, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/home/home.dart';

class HomeScreen extends ConsumerWidget {
  // ignore: use_super_parameters
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularJobsAsync = ref.watch(popularJobsProvider);
    final statsAsync = ref.watch(jobStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh both providers
            ref.refresh(popularJobsProvider);
            ref.refresh(jobStatsProvider);
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // For pull to refresh
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                const HomeHeader(),
                const SizedBox(height: 24),

                // Quick Stats with real data
                statsAsync.when(
                  data: (stats) => QuickStats(stats: stats),
                  loading: () => const QuickStatsLoading(),
                  error: (_, __) => QuickStats(
                    stats: {
                      'totalJobs': 0,
                      'applications': 0,
                      'interviews': 0,
                      'offers': 0,
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Applications (still dummy for now)
                const RecentApplications(),
                const SizedBox(height: 24),

                // Popular Jobs with real data
                popularJobsAsync.when(
                  data: (jobs) => PopularJobs(jobs: jobs),
                  loading: () => const PopularJobsLoading(),
                  error: (error, __) => PopularJobsError(error: error),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}
