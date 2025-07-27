// ignore_for_file: unused_result, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/shared/shared_widgets.dart';
import 'package:job_finder_app/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResumeSection extends ConsumerWidget {
  final List<UserResume> resumes;

  // ignore: use_super_parameters
  const ResumeSection({Key? key, required this.resumes}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resume',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push('/upload-resume'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Upload'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (resumes.isEmpty)
            SharedWidgets.buildEmptyState(
              'No resume uploaded yet',
              'Upload your resume to start applying for jobs',
              Icons.description_outlined,
            )
          else
            ...resumes
                .map((resume) => _buildResumeItem(resume, ref, context))
                // ignore: unnecessary_to_list_in_spreads
                .toList(),
        ],
      ),
    );
  }

  Widget _buildResumeItem(
    UserResume resume,
    WidgetRef ref,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: resume.isPrimary
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.description,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resume.fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (resume.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Uploaded ${_formatDate(resume.uploadedAt)}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            ),
          ),

          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: AppColors.grey600),
            itemBuilder: (context) => [
              if (!resume.isPrimary)
                const PopupMenuItem(
                  value: 'primary',
                  child: Row(
                    children: [
                      Icon(Icons.star_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Set as Primary'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) =>
                _handleResumeAction(value, resume, ref, context),
          ),
        ],
      ),
    );
  }

  void _handleResumeAction(
    String action,
    UserResume resume,
    WidgetRef ref,
    BuildContext context,
  ) async {
    switch (action) {
      case 'primary':
        await _setPrimaryResume(resume, ref, context);
        break;
      case 'download':
        await _downloadResume(resume, context);
        break;
      case 'delete':
        await _deleteResume(resume, ref, context);
        break;
    }
  }

  Future<void> _setPrimaryResume(
    UserResume resume,
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // Unset all primary resumes
      await supabase
          .from('user_resumes')
          .update({'is_primary': false})
          .eq('user_id', user.id);

      // Set this resume as primary
      await supabase
          .from('user_resumes')
          .update({'is_primary': true})
          .eq('id', resume.id);

      ref.refresh(userResumesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primary resume updated!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadResume(UserResume resume, BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resume URL: ${resume.fileUrl}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteResume(
    UserResume resume,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Are you sure you want to delete "${resume.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Delete',
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final supabase = Supabase.instance.client;

        // Extract file path from URL for deletion
        final uri = Uri.parse(resume.fileUrl);
        final pathSegments = uri.pathSegments;
        final fileName = pathSegments.length >= 2
            ? pathSegments.sublist(2).join('/')
            : resume.fileName;

        // Delete from storage
        await supabase.storage.from('resumes').remove([fileName]);

        // Delete from database
        await supabase.from('user_resumes').delete().eq('id', resume.id);

        ref.refresh(userResumesProvider);

        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(
            content: Text('Resume deleted successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text('Error deleting resume: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
