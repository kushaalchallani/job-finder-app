import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/models/job_opening.dart';

class JobCreationData {
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

  JobCreationData({
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

Future<JobOpening> createJob({required JobCreationData jobData}) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  // Validate required fields only for active jobs
  if (jobData.status == 'active') {
    if (jobData.title.trim().isEmpty) {
      throw Exception('Job title is required');
    }
    if (jobData.companyName.trim().isEmpty) {
      throw Exception('Company name is required');
    }
    if (jobData.location.trim().isEmpty) {
      throw Exception('Location is required');
    }
    if (jobData.description.trim().isEmpty) {
      throw Exception('Job description is required');
    }
  }

  final data = {
    'recruiter_id': user.id,
    'title': jobData.title.trim().isEmpty ? 'Draft Job' : jobData.title.trim(),
    'company_name': jobData.companyName.trim().isEmpty
        ? 'Draft Company'
        : jobData.companyName.trim(),
    'location': jobData.location.trim().isEmpty
        ? 'Draft Location'
        : jobData.location.trim(),
    'job_type': jobData.jobType,
    'experience_level': jobData.experienceLevel,
    'description': jobData.description.trim().isEmpty
        ? 'Draft description'
        : jobData.description.trim(),
    'salary_range': jobData.salaryRange?.trim().isEmpty == true
        ? null
        : jobData.salaryRange?.trim(),
    'requirements': jobData.requirements,
    'benefits': jobData.benefits,
    'status': jobData.status,
  };

  try {
    final response = await Supabase.instance.client
        .from('job_openings')
        .insert(data)
        .select()
        .single();

    return JobOpening.fromJson(response);
  } catch (e) {
    // If the regular insert fails due to trigger issues, try RPC
    try {
      final response = await Supabase.instance.client.rpc(
        'insert_job_without_triggers',
        params: data,
      );

      return JobOpening.fromJson(response);
    } catch (rpcError) {
      throw Exception('Failed to create job: $rpcError');
    }
  }
}

void clearJobForm({
  required TextEditingController titleController,
  required TextEditingController companyController,
  required TextEditingController locationController,
  required TextEditingController descriptionController,
  required TextEditingController salaryRangeController,
  required TextEditingController requirementController,
  required TextEditingController benefitController,
  required VoidCallback onStateChanged,
}) {
  titleController.clear();
  companyController.clear();
  locationController.clear();
  descriptionController.clear();
  salaryRangeController.clear();
  requirementController.clear();
  benefitController.clear();

  onStateChanged();
}
