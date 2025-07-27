import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/job_card.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/search_states.dart';

class JobList extends ConsumerWidget {
  final List<JobOpening> allJobs;
  final String searchQuery;
  final String selectedFilter;
  final VoidCallback onRefresh;
  final VoidCallback onClearFilters;

  const JobList({
    Key? key,
    required this.allJobs,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onRefresh,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter jobs based on search and filters
    final filteredJobs = allJobs.where((job) {
      final matchesSearch =
          searchQuery.isEmpty ||
          job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.companyName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesJobType =
          selectedFilter == 'All' ||
          job.jobType.toLowerCase() == selectedFilter.toLowerCase();

      return matchesSearch && matchesJobType;
    }).toList();

    if (filteredJobs.isEmpty && allJobs.isNotEmpty) {
      return SearchStates.buildNoResultsState(onClearFilters);
    }

    if (filteredJobs.isEmpty) {
      return SearchStates.buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredJobs.length,
        itemBuilder: (context, index) {
          final job = filteredJobs[index];
          return JobCard(job: job);
        },
      ),
    );
  }
}
