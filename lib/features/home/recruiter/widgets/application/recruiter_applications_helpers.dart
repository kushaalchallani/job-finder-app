import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';

// Provider to get all applications for recruiter's jobs
final allRecruiterApplicationsProvider = FutureProvider<List<JobApplication>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // First get all jobs by this recruiter
    final jobs = await Supabase.instance.client
        .from('job_openings')
        .select('id')
        .eq('recruiter_id', user.id);

    if (jobs.isEmpty) return [];

    // Get all applications for these jobs
    final jobIds = jobs.map((job) => job['id']).toList();

    final applicationsResponse = await Supabase.instance.client
        .from('job_applications')
        .select('*')
        .inFilter('job_id', jobIds)
        .order('applied_at', ascending: false);

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
    throw Exception('Failed to fetch applications: $e');
  }
});

void viewApplicantProfile(BuildContext context, JobApplication application) {
  context.push('/applicant-profile', extra: application);
}

Widget buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    ),
  );
}

Future<void> updateApplicationStatus(
  BuildContext context,
  JobApplication application,
  WidgetRef ref,
) async {
  final statusController = TextEditingController(text: application.status);
  final notesController = TextEditingController(
    text: application.recruiterNotes ?? '',
  );

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Update Status - ${application.userFullName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: application.status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'reviewed', child: Text('Reviewed')),
              DropdownMenuItem(
                value: 'shortlisted',
                child: Text('Shortlisted'),
              ),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
            ],
            onChanged: (value) {
              if (value != null) {
                statusController.text = value;
              }
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(controller: notesController, label: 'Notes (Optional)'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          text: 'Update',
          onPressed: () async {
            try {
              final supabase = Supabase.instance.client;
              await supabase
                  .from('job_applications')
                  .update({
                    'status': statusController.text,
                    'recruiter_notes': notesController.text,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', application.id);

              if (context.mounted) {
                Navigator.pop(context);
                // Refresh the provider to update the UI
                ref.refresh(allRecruiterApplicationsProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application status updated successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating status: ${e.toString()}'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
      ],
    ),
  );
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${date.day}/${date.month}/${date.year}';
  }
}
