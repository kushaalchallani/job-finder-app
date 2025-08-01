// lib/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/providers/auth_provider.dart';

// User Profile Provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null;
  }

  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserProfile.fromJson(response);
  } catch (e) {
    return null;
  }
});

// Recruiter Profile Provider - fetches a specific user's profile by ID
final recruiterProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  userId,
) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return UserProfile.fromJson(response);
  } catch (e) {
    // Handle any other errors gracefully
    return null;
  }
});

// User Experiences Provider
final userExperiencesProvider = FutureProvider<List<UserExperience>>((
  ref,
) async {
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    final response = await supabase
        .from('user_experiences')
        .select()
        .eq('user_id', user.id)
        .order('start_date', ascending: false);
    return response.map((exp) => UserExperience.fromJson(exp)).toList();
  } catch (e) {
    return [];
  }
});

// User Skills Provider
final userSkillsProvider = FutureProvider<List<UserSkill>>((ref) async {
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    final response = await supabase
        .from('user_skills')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return response.map((skill) => UserSkill.fromJson(skill)).toList();
  } catch (e) {
    return [];
  }
});

// User Resumes Provider
final userResumesProvider = FutureProvider<List<UserResume>>((ref) async {
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  try {
    final response = await supabase
        .from('user_resumes')
        .select()
        .eq('user_id', user.id)
        .order('uploaded_at', ascending: false);
    return response.map((resume) => UserResume.fromJson(resume)).toList();
  } catch (e) {
    return [];
  }
});

// Profile Completion Provider
final profileCompletionProvider = Provider<double>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final experiencesAsync = ref.watch(userExperiencesProvider);
  final skillsAsync = ref.watch(userSkillsProvider);
  final resumesAsync = ref.watch(userResumesProvider);
  final educationAsync = ref.watch(userEducationProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile == null) return 0.0;

      double completion = 0.0;
      int totalFields = 12; // increase fields by education's weight

      // Basic info (5 fields)
      if (profile.fullName?.isNotEmpty == true) completion += 1;
      if (profile.email.isNotEmpty) completion += 1;
      if (profile.phone?.isNotEmpty == true) completion += 1;
      if (profile.location?.isNotEmpty == true) completion += 1;
      if (profile.bio?.isNotEmpty == true) completion += 1;

      // Experience (2 fields)
      experiencesAsync.whenData((experiences) {
        if (experiences.isNotEmpty) completion += 2;
      });

      // Skills (2 fields)
      skillsAsync.whenData((skills) {
        if (skills.isNotEmpty) completion += 2;
      });

      // Resume (1 field)
      resumesAsync.whenData((resumes) {
        if (resumes.isNotEmpty) completion += 1;
      });

      // Education (2 fields, or adjust weight as you like)
      educationAsync.whenData((educations) {
        if (educations.isNotEmpty) completion += 2;
      });

      return completion / totalFields;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// User Education Provider
final userEducationProvider = FutureProvider<List<UserEducation>>((ref) async {
  // Watch auth state to refresh when user changes
  ref.watch(authStateProvider);

  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return [];

  try {
    final response = await supabase
        .from('user_education') // <-- your table name
        .select()
        .eq('user_id', user.id)
        .order('start_date', ascending: false);

    return (response as List)
        .map((edu) => UserEducation.fromJson(edu))
        .toList();
  } catch (e) {
    return [];
  }
});
