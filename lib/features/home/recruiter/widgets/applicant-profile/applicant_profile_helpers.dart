// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/models/job_application.dart';

Future<Map<String, dynamic>> loadApplicantProfile(
  JobApplication application,
) async {
  final supabase = Supabase.instance.client;

  try {
    // Fetch user profile
    final profileResponse = await supabase
        .from('profiles')
        .select()
        .eq('id', application.userId)
        .single();

    // Fetch user experience
    final experienceResponse = await supabase
        .from('user_experiences')
        .select()
        .eq('user_id', application.userId)
        .order('start_date', ascending: false);

    // Fetch user education
    final educationResponse = await supabase
        .from('user_education')
        .select()
        .eq('user_id', application.userId)
        .order('start_date', ascending: false);

    // Fetch user skills
    final skillsResponse = await supabase
        .from('user_skills')
        .select()
        .eq('user_id', application.userId)
        .order('created_at', ascending: false);

    // Fetch user resume
    final resumeResponse = await supabase
        .from('user_resumes')
        .select()
        .eq('user_id', application.userId)
        .eq('is_primary', true)
        .limit(1);

    return {
      'profile': profileResponse,
      'experience': experienceResponse,
      'education': educationResponse,
      'skills': skillsResponse,
      'resume': resumeResponse.isNotEmpty ? resumeResponse.first : null,
    };
  } catch (e) {
    throw Exception('Failed to load applicant profile: $e');
  }
}

String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  } else if (difference < 7) {
    return '$difference days ago';
  } else {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

Widget buildStatusChip(String status) {
  Color color;
  String label;

  switch (status.toLowerCase()) {
    case 'pending':
      color = Colors.orange;
      label = 'Pending';
      break;
    case 'reviewed':
      color = Colors.blue;
      label = 'Reviewed';
      break;
    case 'shortlisted':
      color = Colors.purple;
      label = 'Shortlisted';
      break;
    case 'rejected':
      color = Colors.red;
      label = 'Rejected';
      break;
    case 'accepted':
      color = Colors.green;
      label = 'Accepted';
      break;
    default:
      color = Colors.grey;
      label = status;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    ),
  );
}

Future<void> showUpdateApplicationStatusDialog(
  BuildContext context,
  JobApplication application,
) async {
  final statusController = TextEditingController(text: application.status);
  final notesController = TextEditingController(
    text: application.recruiterNotes ?? '',
  );

  return showDialog(
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
                    'recruiter_notes': notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    'updated_at': DateTime.now().toIso8601String(),
                  })
                  .eq('id', application.id);

              if (context.mounted) {
                Navigator.pop(context);
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
