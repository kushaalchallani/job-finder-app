import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
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
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SaveButton(
              jobId: widget.job.id,
              onSaved: (isSaved) {
                if (mounted) {
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
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _ApplyButton(
              isApplying: _isApplying,
              onApply: _showApplyDialog,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog() {
    showDialog(
      context: context,
      builder: (context) => _ApplyDialog(
        onApply: () {
          Navigator.pop(context);
          _applyForJob();
        },
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

class _SaveButton extends ConsumerWidget {
  final String jobId;
  final Function(bool) onSaved;

  const _SaveButton({required this.jobId, required this.onSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSavedAsync = ref.watch(isJobSavedProvider(jobId));

    return isSavedAsync.when(
      data: (isSaved) => _SaveButtonContent(
        isSaved: isSaved,
        onTap: () async {
          final success = await ref
              .read(savedJobsNotifierProvider.notifier)
              .toggleSavedJob(jobId, ref);

          if (success) {
            onSaved(isSaved);
          }
        },
      ),
      loading: () => const _SaveButtonContent(isSaved: false),
      error: (_, __) => const _SaveButtonContent(isSaved: false),
    );
  }
}

class _SaveButtonContent extends StatelessWidget {
  final bool isSaved;
  final VoidCallback? onTap;

  const _SaveButtonContent({required this.isSaved, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSaved ? AppColors.primary : AppColors.grey300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                color: isSaved ? AppColors.primary : AppColors.grey600,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Save',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSaved ? AppColors.primary : AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final bool isApplying;
  final VoidCallback onApply;

  const _ApplyButton({required this.isApplying, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.brandBlue],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isApplying ? null : onApply,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isApplying) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                'Apply Now',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyDialog extends StatelessWidget {
  final VoidCallback onApply;

  const _ApplyDialog({required this.onApply});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Apply for Job',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      content: const Text(
        'Are you sure you want to apply for this position? Make sure your profile and resume are up to date.',
        style: TextStyle(fontSize: 16, color: AppColors.textLight),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _DialogApplyButton(onApply: onApply),
      ],
    );
  }
}

class _DialogApplyButton extends StatelessWidget {
  final VoidCallback onApply;

  const _DialogApplyButton({required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.brandBlue],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Apply',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
