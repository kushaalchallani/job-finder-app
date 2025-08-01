import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';

// Provider for recruiter's job postings
final recruiterJobsProvider = FutureProvider<List<JobOpening>>((ref) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    final response = await Supabase.instance.client
        .from('job_openings')
        .select('''
          *,
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('recruiter_id', user.id)
        .order('created_at', ascending: false);

    final jobs = response.map((job) {
      final profile = job['profiles'] as Map<String, dynamic>?;
      final companyImageUrl = profile?['company_image_url'] as String?;

      return JobOpening.fromJson({
        ...job,
        'company_image_url': companyImageUrl,
      });
    }).toList();

    return jobs;
  } catch (e) {
    throw Exception('Failed to fetch recruiter jobs: $e');
  }
});

// Provider for recruiter job statistics
final recruiterJobStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    final jobs = await Supabase.instance.client
        .from('job_openings')
        .select('id, status')
        .eq('recruiter_id', user.id);

    int activeJobs = 0;
    int pausedJobs = 0;
    int totalJobs = jobs.length;

    for (final job in jobs) {
      final status = job['status'] as String?;
      if (status == 'active') {
        activeJobs++;
      } else if (status == 'paused') {
        pausedJobs++;
      }
    }

    return {'active': activeJobs, 'paused': pausedJobs, 'total': totalJobs};
  } catch (e) {
    throw Exception('Failed to fetch job statistics: $e');
  }
});
