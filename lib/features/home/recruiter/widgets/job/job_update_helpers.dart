import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobUpdateData {
  final String id;
  final String title;
  final String companyName;
  final String location;
  final String jobType;
  final String experienceLevel;
  final String description;
  final String? salaryRange;
  final List<String> requirements;
  final List<String> benefits;
  final String status;

  JobUpdateData({
    required this.id,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    required this.description,
    this.salaryRange,
    required this.requirements,
    required this.benefits,
    required this.status,
  });
}

Future<void> updateJob({
  required JobUpdateData jobData,
  required VoidCallback onSuccess,
  required Function(String) onError,
  required VoidCallback onLoading,
  required VoidCallback onLoadingComplete,
}) async {
  onLoading();

  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final data = {
      'title': jobData.title,
      'company_name': jobData.companyName,
      'location': jobData.location,
      'job_type': jobData.jobType,
      'experience_level': jobData.experienceLevel,
      'description': jobData.description,
      'salary_range': jobData.salaryRange,
      'requirements': jobData.requirements,
      'benefits': jobData.benefits,
      'status': jobData.status,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await supabase.from('job_openings').update(data).eq('id', jobData.id);
    onSuccess();
  } catch (e) {
    onError(e.toString());
  } finally {
    onLoadingComplete();
  }
}
