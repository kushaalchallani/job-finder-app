import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';

// Analytics data model
class RecruiterAnalytics {
  final Map<String, int> applicationStatusCounts;
  final List<ApplicationTrend> weeklyTrends;
  final List<JobPerformance> topPerformingJobs;
  final Map<String, double> conversionRates;
  final double averageTimeToFill;
  final int totalViews;
  final int totalApplications;
  final int totalJobs;

  RecruiterAnalytics({
    required this.applicationStatusCounts,
    required this.weeklyTrends,
    required this.topPerformingJobs,
    required this.conversionRates,
    required this.averageTimeToFill,
    required this.totalViews,
    required this.totalApplications,
    required this.totalJobs,
  });
}

class ApplicationTrend {
  final String week;
  final int applications;
  final int views;

  ApplicationTrend({
    required this.week,
    required this.applications,
    required this.views,
  });
}

class JobPerformance {
  final String jobId;
  final String jobTitle;
  final int applications;
  final int views;
  final double conversionRate;
  final String status;

  JobPerformance({
    required this.jobId,
    required this.jobTitle,
    required this.applications,
    required this.views,
    required this.conversionRate,
    required this.status,
  });
}

// Provider for recruiter analytics
final recruiterAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // Get all jobs for this recruiter
    final jobsResponse = await Supabase.instance.client
        .from('job_openings')
        .select('id, title, status, created_at')
        .eq('recruiter_id', user.id)
        .order('created_at', ascending: false);

    if (jobsResponse.isEmpty) {
      return {
        'totalJobs': 0,
        'activeJobs': 0,
        'totalApplications': 0,
        'recentJobs': [],
        'applicationTrends': [],
      };
    }

    // Get applications for all jobs
    final jobIds = jobsResponse.map((job) => job['id']).toList();
    final applicationsResponse = await Supabase.instance.client
        .from('job_applications')
        .select('id, job_id, status, created_at')
        .inFilter('job_id', jobIds);

    // Calculate statistics
    int activeJobs = 0;
    int totalApplications = 0;
    Map<String, int> statusCounts = {};

    for (final job in jobsResponse) {
      if (job['status'] == 'active') {
        activeJobs++;
      }
    }

    for (final application in applicationsResponse) {
      totalApplications++;
      final status = application['status'] as String? ?? 'pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    // Get recent jobs (last 5)
    final recentJobs = jobsResponse
        .take(5)
        .map(
          (job) => {
            'id': job['id'],
            'title': job['title'],
            'status': job['status'],
            'created_at': job['created_at'],
          },
        )
        .toList();

    // Get application trends (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentApplications = applicationsResponse.where((app) {
      final createdAt = DateTime.parse(app['created_at']);
      return createdAt.isAfter(thirtyDaysAgo);
    }).toList();

    final applicationTrends = recentApplications
        .map(
          (app) => {
            'date': app['created_at'].split('T')[0],
            'status': app['status'],
          },
        )
        .toList();

    return {
      'totalJobs': jobsResponse.length,
      'activeJobs': activeJobs,
      'totalApplications': totalApplications,
      'recentJobs': recentJobs,
      'applicationTrends': applicationTrends,
      'statusCounts': statusCounts,
    };
  } catch (e) {
    throw Exception('Failed to fetch analytics: $e');
  }
});

// Provider for recent applications
final recentApplicationsProvider = FutureProvider<List<JobApplication>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // Get recruiter's job IDs
    final jobsResponse = await Supabase.instance.client
        .from('job_openings')
        .select('id')
        .eq('recruiter_id', user.id);

    if (jobsResponse.isEmpty) return [];

    final jobIds = jobsResponse.map((job) => job['id']).toList();

    // Fetch recent applications with separate queries for better data mapping
    final applicationsResponse = await Supabase.instance.client
        .from('job_applications')
        .select('*')
        .inFilter('job_id', jobIds)
        .order('applied_at', ascending: false)
        .limit(10);

    final List<JobApplication> applications = [];

    for (final app in applicationsResponse) {
      // Fetch job details
      final jobResponse = await Supabase.instance.client
          .from('job_openings')
          .select('title, company_name, location')
          .eq('id', app['job_id'])
          .single();

      // Fetch user profile
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('full_name, email, phone, location')
          .eq('id', app['user_id'])
          .maybeSingle();

      // Combine the data
      final combinedData = {
        ...app,
        'job_title': jobResponse['title'],
        'company_name': jobResponse['company_name'],
        'job_location': jobResponse['location'],
        'user_full_name': profileResponse?['full_name'] ?? 'Unknown User',
        'user_email': profileResponse?['email'] ?? 'No email',
        'user_phone': profileResponse?['phone'],
        'user_location': profileResponse?['location'],
      };

      applications.add(JobApplication.fromJson(combinedData));
    }

    return applications;
  } catch (e) {
    throw Exception('Failed to fetch recent applications: $e');
  }
});
