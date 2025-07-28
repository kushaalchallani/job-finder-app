import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/job_seeker/services/application_service.dart';

// Provider for user's applications
final userApplicationsProvider = FutureProvider<List<JobApplication>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  return ApplicationService.getUserApplications(userId: user.id);
});

// Provider for application statistics
final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  return ApplicationService.getUserApplicationStats(userId: user.id);
});

// Provider to check if user has applied for a specific job
final hasAppliedProvider = FutureProvider.family<bool, String>((
  ref,
  jobId,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;

  return ApplicationService.hasUserApplied(jobId: jobId, userId: user.id);
});

// Provider for job applications (for recruiters)
final jobApplicationsProvider =
    FutureProvider.family<List<JobApplication>, String>((ref, jobId) async {
      return ApplicationService.getJobApplications(jobId: jobId);
    });

// State notifier for application operations
class ApplicationState {
  final bool isLoading;
  final String? error;
  final JobApplication? lastApplication;

  const ApplicationState({
    this.isLoading = false,
    this.error,
    this.lastApplication,
  });

  ApplicationState copyWith({
    bool? isLoading,
    String? error,
    JobApplication? lastApplication,
  }) {
    return ApplicationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastApplication: lastApplication ?? this.lastApplication,
    );
  }
}

class ApplicationNotifier extends StateNotifier<ApplicationState> {
  ApplicationNotifier() : super(const ApplicationState());

  Future<bool> applyForJob({
    required String jobId,
    String? coverLetter,
    String? resumeUrl,
    String? resumeFileName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'User not authenticated',
        );
        return false;
      }

      final application = await ApplicationService.applyForJob(
        jobId: jobId,
        userId: user.id,
        coverLetter: coverLetter,
        resumeUrl: resumeUrl,
        resumeFileName: resumeFileName,
      );

      if (application != null) {
        state = state.copyWith(isLoading: false, lastApplication: application);

        // Invalidate the applications list to refresh it
        // This will trigger a rebuild of widgets that depend on userApplicationsProvider
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to submit application',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearLastApplication() {
    state = state.copyWith(lastApplication: null);
  }
}

final applicationNotifierProvider =
    StateNotifierProvider<ApplicationNotifier, ApplicationState>((ref) {
      return ApplicationNotifier();
    });
