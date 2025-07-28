import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<void> createJob({
  required JobCreationData jobData,
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
      'recruiter_id': user.id,
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
    };

    await supabase.from('job_openings').insert(data);
    onSuccess();
  } catch (e) {
    onError(e.toString());
  } finally {
    onLoadingComplete();
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
