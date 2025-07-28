import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/providers/recruiter_jobs_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/job_search_bar.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/empty_jobs_state.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/recruiter_job_card.dart';

class RecruiterJobsScreen extends ConsumerStatefulWidget {
  const RecruiterJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterJobsScreen> createState() =>
      _RecruiterJobsScreenState();
}

class _RecruiterJobsScreenState extends ConsumerState<RecruiterJobsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(recruiterJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-job');
        },
        tooltip: 'Create Job',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Jobs text and search
            Padding(
              padding: const EdgeInsets.all(16),
              child: JobSearchBar(
                searchQuery: _searchQuery,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onClearSearch: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
            ),
            // Job List
            Expanded(
              child: jobsAsync.when(
                data: (jobs) {
                  final filteredJobs = _searchQuery.isEmpty
                      ? jobs
                      : jobs.where((job) {
                          final query = _searchQuery.toLowerCase();
                          return job.title.toLowerCase().contains(query) ||
                              job.companyName.toLowerCase().contains(query) ||
                              job.location.toLowerCase().contains(query);
                        }).toList();

                  if (filteredJobs.isEmpty) {
                    return const EmptyJobsState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(recruiterJobsProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredJobs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return RecruiterJobCard(job: job);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                // ignore: prefer_interpolation_to_compose_strings
                error: (e, _) => Center(child: Text('Error: ' + e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
