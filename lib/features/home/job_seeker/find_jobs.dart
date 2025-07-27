// lib/features/auth/pages/home/job_seeker/find_jobs_refactored.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/search.dart';

class FindJobsScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const FindJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends ConsumerState<FindJobsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header and Search
            SearchHeader(
              searchQuery: _searchQuery,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onFilterPressed: () {
                // Show filter modal
              },
            ),

            // Filter Chips
            FilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) =>
                  setState(() => _selectedFilter = filter),
            ),

            // Job List
            Expanded(
              child: jobsAsync.when(
                data: (jobs) => JobList(
                  allJobs: jobs,
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                  onRefresh: () => ref.refresh(jobListProvider),
                  onClearFilters: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedFilter = 'All';
                    });
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => SearchStates.buildErrorState(
                  error,
                  () => ref.refresh(jobListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
