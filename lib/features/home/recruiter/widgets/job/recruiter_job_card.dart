// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/providers/recruiter_jobs_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class RecruiterJobCard extends ConsumerWidget {
  final JobOpening job;

  // ignore: use_super_parameters
  const RecruiterJobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;
    String statusLabel;

    switch (job.status) {
      case 'active':
        statusColor = AppColors.success;
        statusLabel = 'Active';
        break;
      case 'paused':
        statusColor = AppColors.warning;
        statusLabel = 'Paused';
        break;
      case 'closed':
        statusColor = AppColors.grey400;
        statusLabel = 'Closed';
        break;
      default:
        statusColor = AppColors.blueGrey;
        statusLabel = job.status;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Flexible(
                  child: Text(
                    job.companyName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '·',
                    style: TextStyle(color: AppColors.grey400, fontSize: 16),
                  ),
                ),
                Flexible(
                  child: Text(
                    job.location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Text(
              job.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Edit',
                  onPressed: () async {
                    await context.push('/edit-job/${job.id}', extra: job);
                    ref.refresh(recruiterJobsProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  tooltip: 'Delete',
                  onPressed: () async {
                    final supabase = Supabase.instance.client;
                    await supabase
                        .from('job_openings')
                        .delete()
                        .eq('id', job.id);
                    ref.refresh(recruiterJobsProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Job deleted successfully!'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const Spacer(),
                Text(
                  'Posted: '
                  '${job.createdAt.day.toString().padLeft(2, '0')}-'
                  '${job.createdAt.month.toString().padLeft(2, '0')}-'
                  '${job.createdAt.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
