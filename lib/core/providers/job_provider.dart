// lib/providers/job_provider.dart (or wherever you have your providers)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import your existing JobOpening model
import 'package:job_finder_app/core/providers/auth_provider.dart';

// Provider to fetch active job openings
final jobListProvider = FutureProvider<List<JobOpening>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('job_openings')
        .select('''
          *,
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return response.map((job) {
      // Extract company image URL
      final recruiterProfile = job['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      final jobWithPicture = {...job, 'company_picture_url': companyPictureUrl};
      return JobOpening.fromJson(jobWithPicture);
    }).toList();
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
    // Get all active jobs with their application counts and view counts
    final jobsWithApplications = await supabase
        .from('job_openings')
        .select('''
          *,
          job_applications!job_id(count),
          job_views!job_id(count),
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('status', 'active')
        .order('created_at', ascending: false);

    // Calculate popularity score for each job
    final jobsWithScores = <Map<String, dynamic>>[];

    for (final job in jobsWithApplications) {
      // Handle null values properly - Supabase might return null instead of empty array
      final applications = job['job_applications'];
      final views = job['job_views'];

      final applicationCount = applications is List ? applications.length : 0;
      final viewCount = views is List ? views.length : 0;
      final createdAt = DateTime.parse(job['created_at']);
      final daysSinceCreation = DateTime.now().difference(createdAt).inDays;

      // Calculate popularity score based on multiple factors
      double popularityScore = 0.0;

      // 1. Application count (25% weight) - Most important factor
      popularityScore += (applicationCount * 15);

      // 2. View count (15% weight) - Engagement indicator
      popularityScore += (viewCount * 2);

      // 3. Recency bonus (35% weight) - Newer jobs get more points
      final recencyBonus = daysSinceCreation <= 3
          ? 100
          : daysSinceCreation <= 7
          ? 80
          : daysSinceCreation <= 14
          ? 60
          : daysSinceCreation <= 30
          ? 40
          : 20;
      popularityScore += recencyBonus;

      // 4. Job type bonus (15% weight)
      final jobType = job['job_type']?.toString().toLowerCase() ?? '';
      if (jobType == 'full-time') {
        popularityScore += 30;
      } else if (jobType == 'remote') {
        popularityScore += 25;
      } else if (jobType == 'part-time') {
        popularityScore += 15;
      } else if (jobType == 'contract') {
        popularityScore += 10;
      } else {
        popularityScore += 5;
      }

      // 5. Salary information bonus (10% weight)
      if (job['salary_range'] != null) {
        popularityScore += 15;
      }

      // 6. Location bonus - Popular locations get bonus
      final location = job['location']?.toString().toLowerCase() ?? '';
      if (location.contains('remote') || location.contains('work from home')) {
        popularityScore += 20;
      }

      jobsWithScores.add({...job, 'popularity_score': popularityScore});
    }

    // Sort by popularity score and take top 6
    jobsWithScores.sort(
      (a, b) => (b['popularity_score'] as double).compareTo(
        a['popularity_score'] as double,
      ),
    );

    final topJobs = jobsWithScores.take(6).toList();

    // Ensure we return at least 4 jobs if available
    if (topJobs.length < 4 && jobsWithApplications.length >= 4) {
      final remainingJobs = jobsWithApplications
          .where((job) => !topJobs.any((topJob) => topJob['id'] == job['id']))
          .take(4 - topJobs.length)
          .toList();

      topJobs.addAll(remainingJobs);
    }

    return topJobs.map((job) {
      // Add application and view counts to the job data
      final applications = job['job_applications'];
      final views = job['job_views'];
      final applicationCount = applications is List ? applications.length : 0;
      final viewCount = views is List ? views.length : 0;

      // Extract recruiter profile picture URL
      final recruiterProfile = job['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      final jobWithCounts = {
        ...job,
        'application_count': applicationCount,
        'view_count': viewCount,
        'company_picture_url': companyPictureUrl,
      };
      return JobOpening.fromJson(jobWithCounts);
    }).toList();
  } catch (e) {
    // Fallback: just get recent active jobs
    final response = await supabase
        .from('job_openings')
        .select('''
          *,
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(6);

    return response.map((job) {
      // Extract company image URL
      final recruiterProfile = job['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      // Add default counts for fallback
      final jobWithCounts = {
        ...job,
        'application_count': 0,
        'view_count': 0,
        'company_picture_url': companyPictureUrl,
      };
      return JobOpening.fromJson(jobWithCounts);
    }).toList();
  }
});

// Provider for job stats (for dashboard cards)
// lib/providers/job_provider.dart - Update this part

final jobStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  try {
    // Get total active jobs
    final jobs = await supabase
        .from('job_openings')
        .select('id')
        .eq('status', 'active');

    // Get user's application stats if user is logged in
    Map<String, int> userStats = {'applications': 0, 'offers': 0};

    if (user != null) {
      try {
        // Get user's applications using the correct column name
        List<Map<String, dynamic>> applications;
        try {
          applications = await supabase
              .from('job_applications')
              .select('*')
              .eq('user_id', user.id);
        } catch (queryError) {
          rethrow;
        }

        int totalApplications = applications.length;

        // Check for different possible offer statuses
        int offers = applications.where((app) {
          final status = app['status']?.toString().toLowerCase() ?? '';
          return status == 'offer_received' ||
              status == 'offer_accepted' ||
              status == 'accepted';
        }).length;

        userStats = {'applications': totalApplications, 'offers': offers};
      } catch (e) {
        // If user stats fail, keep defaults
      }
    }

    final result = {
      'totalJobs': jobs.length,
      'applications': userStats['applications']!,
      'offers': userStats['offers']!,
    };

    return result;
  } catch (e) {
    return {'totalJobs': 0, 'applications': 0, 'offers': 0};
  }
});

// Test provider to check if providers are working
final testProvider = FutureProvider<String>((ref) async {
  return 'Test successful';
});

// Provider for recent job openings (created by recruiters)
final recentApplicationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;

  try {
    // Get recent job openings created by recruiters with company logos
    final jobs = await supabase
        .from('job_openings')
        .select('''
          id,
          title,
          company_name,
          location,
          job_type,
          salary_range,
          created_at,
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(3); // Limit to 3 most recent

    return jobs.map((job) {
      // Extract company image URL
      final recruiterProfile = job['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      return {...job, 'company_picture_url': companyPictureUrl};
    }).toList();
  } catch (e) {
    return [];
  }
});

// Function to track job view (call this when user views a job)
Future<void> trackJobView(String jobId) async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Record the view (privacy-friendly - no IP tracking)
    await supabase.from('job_views').insert({
      'job_id': jobId,
      'user_id': user?.id, // Optional - can be null for anonymous views
      'viewed_at': DateTime.now().toIso8601String(),
      // No IP address tracking for privacy
    });
  } catch (e) {
    // Silently fail - view tracking shouldn't break the app
  }
}

// Provider to get job view count
final jobViewCountProvider = FutureProvider.family<int, String>((
  ref,
  jobId,
) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('job_views')
        .select('id')
        .eq('job_id', jobId);

    return response.length;
  } catch (e) {
    return 0;
  }
});

// Provider for saved jobs
final savedJobsProvider = FutureProvider<List<JobOpening>>((ref) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  try {
    final response = await supabase
        .from('saved_jobs')
        .select('''
          job_openings!inner(
            *,
            profiles!job_openings_recruiter_id_fkey(company_image_url)
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map((savedJob) {
      final jobData = savedJob['job_openings'] as Map<String, dynamic>;

      // Extract company image URL
      final recruiterProfile = jobData['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      final jobWithPicture = {
        ...jobData,
        'company_picture_url': companyPictureUrl,
      };
      return JobOpening.fromJson(jobWithPicture);
    }).toList();
  } catch (e) {
    throw Exception('Failed to fetch saved jobs: $e');
  }
});

// Provider to check if a specific job is saved
final isJobSavedProvider = FutureProvider.family<bool, String>((
  ref,
  jobId,
) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return false;

  try {
    final response = await supabase
        .from('saved_jobs')
        .select('id')
        .eq('user_id', user.id)
        .eq('job_id', jobId)
        .maybeSingle();

    return response != null;
  } catch (e) {
    return false;
  }
});

// Provider for saved jobs count
final savedJobsCountProvider = FutureProvider<int>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return 0;

  try {
    final response = await supabase
        .from('saved_jobs')
        .select('id')
        .eq('user_id', user.id);

    return response.length;
  } catch (e) {
    return 0;
  }
});

// Saved Jobs Service
class SavedJobsService {
  static final _client = Supabase.instance.client;

  static Future<bool> saveJob(String jobId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client.from('saved_jobs').insert({
        'user_id': user.id,
        'job_id': jobId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unsaveJob(String jobId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('saved_jobs')
          .delete()
          .eq('user_id', user.id)
          .eq('job_id', jobId);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleSavedJob(String jobId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Check if job is already saved
      final existing = await _client
          .from('saved_jobs')
          .select('id')
          .eq('user_id', user.id)
          .eq('job_id', jobId)
          .maybeSingle();

      if (existing != null) {
        // Job is saved, so unsave it
        return await unsaveJob(jobId);
      } else {
        // Job is not saved, so save it
        return await saveJob(jobId);
      }
    } catch (e) {
      return false;
    }
  }
}

// Saved Jobs Notifier for state management
class SavedJobsNotifier extends StateNotifier<AsyncValue<List<JobOpening>>> {
  SavedJobsNotifier() : super(const AsyncValue.loading()) {
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    state = const AsyncValue.loading();
    try {
      final jobs = await _fetchSavedJobs();
      state = AsyncValue.data(jobs);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<List<JobOpening>> _fetchSavedJobs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return [];

    final response = await supabase
        .from('saved_jobs')
        .select('''
          job_openings!inner(
            *,
            profiles!job_openings_recruiter_id_fkey(company_image_url)
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map((savedJob) {
      final jobData = savedJob['job_openings'] as Map<String, dynamic>;

      // Extract company image URL
      final recruiterProfile = jobData['profiles'] as Map<String, dynamic>?;
      final companyPictureUrl = recruiterProfile?['company_image_url'];

      final jobWithPicture = {
        ...jobData,
        'company_picture_url': companyPictureUrl,
      };
      return JobOpening.fromJson(jobWithPicture);
    }).toList();
  }

  Future<bool> toggleSavedJob(String jobId, WidgetRef? ref) async {
    final success = await SavedJobsService.toggleSavedJob(jobId);
    if (success) {
      // Refresh the saved jobs list
      await _loadSavedJobs();
      // Invalidate the specific job's saved status provider
      ref?.invalidate(isJobSavedProvider(jobId));
    }
    return success;
  }

  Future<void> refresh() async {
    await _loadSavedJobs();
  }
}

final savedJobsNotifierProvider =
    StateNotifierProvider<SavedJobsNotifier, AsyncValue<List<JobOpening>>>((
      ref,
    ) {
      return SavedJobsNotifier();
    });
