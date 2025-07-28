// ignore_for_file: unnecessary_null_comparison

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/models/user_profile.dart';

class ApplicationService {
  static final _client = Supabase.instance.client;

  /// Apply for a job
  static Future<JobApplication?> applyForJob({
    required String jobId,
    required String userId,
    String? coverLetter,
    String? resumeUrl,
    String? resumeFileName,
  }) async {
    try {
      // First, get the job details
      final jobResponse = await _client
          .from('job_openings')
          .select()
          .eq('id', jobId)
          .single();

      if (jobResponse == null) {
        throw Exception('Job not found');
      }

      final job = JobOpening.fromJson(jobResponse);

      // Get user profile details
      final userResponse = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (userResponse == null) {
        throw Exception('User profile not found');
      }

      final user = UserProfile.fromJson(userResponse);

      // Check if user has already applied for this job
      final existingApplication = await _client
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingApplication != null) {
        throw Exception('You have already applied for this job');
      }

      // Create the application
      final applicationData = {
        'job_id': jobId,
        'user_id': userId,
        'status': 'pending',
        'applied_at': DateTime.now().toIso8601String(),
        'resume_url': resumeUrl,
        'resume_file_name': resumeFileName,
        'job_title': job.title,
        'company_name': job.companyName,
        'job_location': job.location,
        'user_full_name': user.fullName ?? 'Unknown',
        'user_email': user.email,
        'user_phone': user.phone,
        'user_location': user.location,
      };

      final response = await _client
          .from('job_applications')
          .insert(applicationData)
          .select()
          .single();

      return JobApplication.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all applications for a user
  static Future<List<JobApplication>> getUserApplications({
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('job_applications')
          .select()
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      return response.map((app) => JobApplication.fromJson(app)).toList();
    } catch (e) {
      throw Exception('Failed to fetch applications: $e');
    }
  }

  /// Get all applications for a job (for recruiters)
  static Future<List<JobApplication>> getJobApplications({
    required String jobId,
  }) async {
    try {
      final response = await _client
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .order('applied_at', ascending: false);

      return response.map((app) => JobApplication.fromJson(app)).toList();
    } catch (e) {
      throw Exception('Failed to fetch job applications: $e');
    }
  }

  /// Update application status
  static Future<JobApplication?> updateApplicationStatus({
    required String applicationId,
    required String status,
    String? recruiterNotes,
  }) async {
    try {
      final updateData = {
        'status': status,
        'reviewed_at': DateTime.now().toIso8601String(),
        if (recruiterNotes != null) 'recruiter_notes': recruiterNotes,
      };

      final response = await _client
          .from('job_applications')
          .update(updateData)
          .eq('id', applicationId)
          .select()
          .single();

      return JobApplication.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update application status: $e');
    }
  }

  /// Check if user has applied for a specific job
  static Future<bool> hasUserApplied({
    required String jobId,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('job_applications')
          .select('id')
          .eq('job_id', jobId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Get application statistics for a user
  static Future<Map<String, int>> getUserApplicationStats({
    required String userId,
  }) async {
    try {
      final applications = await getUserApplications(userId: userId);

      int pending = 0;
      int reviewed = 0;
      int shortlisted = 0;
      int rejected = 0;
      int accepted = 0;

      for (final app in applications) {
        switch (app.status) {
          case 'pending':
            pending++;
            break;
          case 'reviewed':
            reviewed++;
            break;
          case 'shortlisted':
            shortlisted++;
            break;
          case 'rejected':
            rejected++;
            break;
          case 'accepted':
            accepted++;
            break;
        }
      }

      return {
        'total': applications.length,
        'pending': pending,
        'reviewed': reviewed,
        'shortlisted': shortlisted,
        'rejected': rejected,
        'accepted': accepted,
      };
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'reviewed': 0,
        'shortlisted': 0,
        'rejected': 0,
        'accepted': 0,
      };
    }
  }
}
