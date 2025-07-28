import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_application.dart';

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

// Provider for comprehensive recruiter analytics
final recruiterAnalyticsProvider = FutureProvider<RecruiterAnalytics>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // Fetch all jobs for the recruiter
    final jobsResponse = await Supabase.instance.client
        .from('job_openings')
        .select('id, title, status, created_at')
        .eq('recruiter_id', user.id)
        .order('created_at', ascending: false);

    // Fetch all applications for these jobs
    final jobIds = jobsResponse.map((job) => job['id']).toList();

    if (jobIds.isEmpty) {
      return RecruiterAnalytics(
        applicationStatusCounts: {},
        weeklyTrends: [],
        topPerformingJobs: [],
        conversionRates: {},
        averageTimeToFill: 0,
        totalViews: 0,
        totalApplications: 0,
        totalJobs: 0,
      );
    }

    final applicationsResponse = await Supabase.instance.client
        .from('job_applications')
        .select('*')
        .inFilter('job_id', jobIds);

    // Process application status counts
    final Map<String, int> statusCounts = {};
    for (final app in applicationsResponse) {
      final status = app['status'] ?? 'pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    // Calculate weekly trends (last 8 weeks)
    final List<ApplicationTrend> weeklyTrends = [];
    final now = DateTime.now();
    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final weekApplications = applicationsResponse.where((app) {
        final appliedAt = DateTime.parse(app['applied_at']);
        return appliedAt.isAfter(weekStart) &&
            appliedAt.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;

      // Mock views data (in real app, you'd track this)
      final weekViews = weekApplications * 3 + (i * 2); // Mock data

      weeklyTrends.add(
        ApplicationTrend(
          week: '${weekStart.month}/${weekStart.day}',
          applications: weekApplications,
          views: weekViews,
        ),
      );
    }

    // Calculate job performance
    final List<JobPerformance> topPerformingJobs = [];
    for (final job in jobsResponse) {
      final jobApplications = applicationsResponse
          .where((app) => app['job_id'] == job['id'])
          .toList();
      // Mock views data since views column doesn't exist yet
      final views = jobApplications.length * 3; // Mock data
      final applications = jobApplications.length;
      final conversionRate = views > 0 ? (applications / views) * 100.0 : 0.0;

      topPerformingJobs.add(
        JobPerformance(
          jobId: job['id'],
          jobTitle: job['title'],
          applications: applications,
          views: views,
          conversionRate: conversionRate,
          status: job['status'],
        ),
      );
    }

    // Sort by applications (top performing)
    topPerformingJobs.sort((a, b) => b.applications.compareTo(a.applications));

    // Calculate conversion rates
    final totalViews = jobsResponse.fold<int>(
      0,
      (sum, job) =>
          sum +
          (applicationsResponse
                  .where((app) => app['job_id'] == job['id'])
                  .length *
              3), // Mock data
    );
    final totalApplications = applicationsResponse.length;
    final overallConversionRate = totalViews > 0
        ? (totalApplications / totalViews) * 100.0
        : 0.0;

    final Map<String, double> conversionRates = {
      'overall': overallConversionRate,
      'this_month': overallConversionRate * 1.2, // Mock data
      'last_month': overallConversionRate * 0.8, // Mock data
    };

    // Calculate average time to fill (mock data for now)
    final averageTimeToFill = 25.5; // days

    return RecruiterAnalytics(
      applicationStatusCounts: statusCounts,
      weeklyTrends: weeklyTrends,
      topPerformingJobs: topPerformingJobs.take(5).toList(), // Top 5
      conversionRates: conversionRates,
      averageTimeToFill: averageTimeToFill,
      totalViews: totalViews,
      totalApplications: totalApplications,
      totalJobs: jobsResponse.length,
    );
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
