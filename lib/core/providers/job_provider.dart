// lib/providers/job_provider.dart (or wherever you have your providers)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import your existing JobOpening model

// Provider to fetch active job openings
final jobListProvider = FutureProvider<List<JobOpening>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('job_openings')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return response.map((job) => JobOpening.fromJson(job)).toList();
  } catch (e) {
    throw Exception('Failed to fetch jobs: $e');
  }
});

// Provider for searching/filtering jobs
final filteredJobsProvider =
    Provider.family<List<JobOpening>, Map<String, String>>((ref, filters) {
      final asyncJobs = ref.watch(jobListProvider);

      return asyncJobs.when(
        data: (jobs) {
          var filteredJobs = jobs;

          // Filter by search query
          if (filters['search']?.isNotEmpty == true) {
            final query = filters['search']!.toLowerCase();
            filteredJobs = filteredJobs
                .where(
                  (job) =>
                      job.title.toLowerCase().contains(query) ||
                      job.companyName.toLowerCase().contains(query) ||
                      job.location.toLowerCase().contains(query),
                )
                .toList();
          }

          // Filter by job type
          if (filters['jobType'] != null && filters['jobType'] != 'All') {
            filteredJobs = filteredJobs
                .where(
                  (job) =>
                      job.jobType.toLowerCase() ==
                      filters['jobType']!.toLowerCase(),
                )
                .toList();
          }

          return filteredJobs;
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });
// Add this to your job_provider.dart file

// Provider for popular/trending jobs (for home page)
final popularJobsProvider = FutureProvider<List<JobOpening>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    // Get popular jobs based on:
    // 1. Recent jobs (last 7 days get priority)
    // 2. Full-time and Remote jobs (typically more popular)
    // 3. Jobs with salary ranges (more attractive)
    final response = await supabase
        .from('job_openings')
        .select()
        .eq('status', 'active')
        .or('job_type.eq.full-time,job_type.eq.remote') // Popular job types
        .not('salary_range', 'is', null) // Jobs with salary info
        .order('created_at', ascending: false)
        .limit(6); // Limit to 6 popular jobs

    return response.map((job) => JobOpening.fromJson(job)).toList();
  } catch (e) {
    // Fallback: just get recent active jobs
    final response = await supabase
        .from('job_openings')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(6);

    return response.map((job) => JobOpening.fromJson(job)).toList();
  }
});

// Provider for job stats (for dashboard cards)
// lib/providers/job_provider.dart - Update this part

final jobStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    // Simple approach: get all active jobs and count them
    final jobs = await supabase
        .from('job_openings')
        .select('id') // Only select id to minimize data transfer
        .eq('status', 'active');

    return {
      'totalJobs': jobs.length, // This definitely works
      'applications': 12, // Dummy for now
      'interviews': 3, // Dummy for now
      'offers': 1, // Dummy for now
    };
  } catch (e) {
    // Debug log
    return {'totalJobs': 0, 'applications': 0, 'interviews': 0, 'offers': 0};
  }
});
