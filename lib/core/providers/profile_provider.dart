// lib/providers/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// User Profile Provider
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  print('[DEBUG] Current user id: ${user?.id}');
  print('[DEBUG] User id type: ${user?.id.runtimeType}');

  if (user == null) {
    print('[DEBUG] No authenticated user found.');
    return null;
  }

  final response = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();
  print('[DEBUG] UserProfile response:');
  print(response);
  return UserProfile.fromJson(response);
});

// User Experiences Provider
final userExperiencesProvider = FutureProvider<List<UserExperience>>((
  ref,
) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  print('[DEBUG] Current user id: ${user?.id}');
  print('[DEBUG] User id type: ${user?.id.runtimeType}');

  if (user == null) {
    print('[DEBUG] No authenticated user found for experiences.');
    return [];
  }

  final response = await supabase
      .from('user_experiences')
      .select()
      .eq('user_id', user.id)
      .order('start_date', ascending: false);
  print('[DEBUG] UserExperiences response:');
  print(response);
  return response.map((exp) => UserExperience.fromJson(exp)).toList();
});

// User Skills Provider
final userSkillsProvider = FutureProvider<List<UserSkill>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  print('[DEBUG] Current user id: ${user?.id}');
  print('[DEBUG] User id type: ${user?.id.runtimeType}');

  if (user == null) {
    print('[DEBUG] No authenticated user found for skills.');
    return [];
  }

  final response = await supabase
      .from('user_skills')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  print('[DEBUG] UserSkills response:');
  print(response);
  return response.map((skill) => UserSkill.fromJson(skill)).toList();
});

// User Resumes Provider
final userResumesProvider = FutureProvider<List<UserResume>>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  print('[DEBUG] Current user id: ${user?.id}');
  print('[DEBUG] User id type: ${user?.id.runtimeType}');

  if (user == null) {
    print('[DEBUG] No authenticated user found for resumes.');
    return [];
  }

  final response = await supabase
      .from('user_resumes')
      .select()
      .eq('user_id', user.id)
      .order('uploaded_at', ascending: false);
  print('[DEBUG] UserResumes response:');
  print(response);
  return response.map((resume) => UserResume.fromJson(resume)).toList();
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
