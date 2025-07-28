// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/core/providers/application_provider.dart';

Future<void> updateApplicationStatus(
  BuildContext context,
  JobApplication application,
  String jobId,
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
            // Update in Supabase
            final supabase = Supabase.instance.client;
            final response = await supabase
                .from('job_applications')
                .update({
                  'status': statusController.text,
                  'recruiter_notes': notesController.text,
                })
                .eq('id', application.id)
                .select()
                .single();

            Navigator.pop(context);

            // ignore: unnecessary_null_comparison
            if (response != null) {
              // Refresh the provider to update the UI
              // ignore: unused_result
              ref.refresh(jobApplicationsProvider(jobId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application status updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update application status.'),
                  backgroundColor: AppColors.error,
                ),
              );
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
