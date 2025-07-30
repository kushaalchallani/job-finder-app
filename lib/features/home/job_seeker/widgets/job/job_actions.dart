import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/providers/application_provider.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';

class JobActions extends ConsumerStatefulWidget {
  final VoidCallback onApply;
  final JobOpening job;

  const JobActions({Key? key, required this.onApply, required this.job})
    : super(key: key);

  @override
  ConsumerState<JobActions> createState() => _JobActionsState();
}

class _JobActionsState extends ConsumerState<JobActions> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Save Button
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final isSavedAsync = ref.watch(
                  isJobSavedProvider(widget.job.id),
                );

                return isSavedAsync.when(
                  data: (isSaved) => OutlinedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(savedJobsNotifierProvider.notifier)
                          .toggleSavedJob(widget.job.id, ref);

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSaved ? 'Job removed from saved' : 'Job saved!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isSaved ? AppColors.primary : AppColors.grey300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.grey600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSaved
                                ? AppColors.primary
                                : AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_outline, color: AppColors.grey600),
                        SizedBox(width: 8),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (_, __) => OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.grey300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_outline, color: AppColors.grey600),
                        SizedBox(width: 8),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Apply Now Button
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: 'Apply Now',
              onPressed: () => _showApplyDialog(),
              isLoading: _isApplying,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for Job'),
        content: const Text(
          'Are you sure you want to apply for this position? Make sure your profile and resume are up to date.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Apply',
            onPressed: () {
              Navigator.pop(context);
              _applyForJob();
            },
          ),
        ],
      ),
    );
  }

  void _applyForJob() async {
    setState(() {
      _isApplying = true;
    });

    try {
      final success = await ref
          .read(applicationNotifierProvider.notifier)
          .applyForJob(jobId: widget.job.id);

      if (mounted) {
        setState(() {
          _isApplying = false;
        });

        if (success) {
          widget.onApply();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          final error = ref.read(applicationNotifierProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to submit application'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isApplying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
