import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_opening.dart';

// Provider for recruiter's job postings
final recruiterJobsProvider = FutureProvider<List<JobOpening>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    final response = await Supabase.instance.client
        .from('job_openings')
        .select()
        .eq('recruiter_id', user.id)
        .order('created_at', ascending: false);

    return response.map((job) => JobOpening.fromJson(job)).toList();
  } catch (e) {
    throw Exception('Failed to fetch recruiter jobs: $e');
  }
});

// Provider for recruiter job statistics
final recruiterJobStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    final jobs = await Supabase.instance.client
        .from('job_openings')
        .select('id, status')
        .eq('recruiter_id', user.id);

    int activeJobs = 0;
    int totalApplications = 0;

    for (final job in jobs) {
      if (job['status'] == 'active') {
        activeJobs++;
      }

      // Count applications for this job
      final applications = await Supabase.instance.client
          .from('job_applications')
          .select('id')
          .eq('job_id', job['id']);

      totalApplications += applications.length;
    }

    return {
      'totalJobs': jobs.length,
      'activeJobs': activeJobs,
      'totalApplications': totalApplications,
    };
  } catch (e) {
    return {'totalJobs': 0, 'activeJobs': 0, 'totalApplications': 0};
  }
});
