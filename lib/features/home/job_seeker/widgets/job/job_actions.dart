import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';

class JobActions extends StatefulWidget {
  final VoidCallback onApply;

  const JobActions({Key? key, required this.onApply}) : super(key: key);

  @override
  State<JobActions> createState() => _JobActionsState();
}

class _JobActionsState extends State<JobActions> {
  bool _isSaved = false;
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
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _isSaved = !_isSaved;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isSaved ? 'Job saved!' : 'Job removed from saved',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: _isSaved ? AppColors.primary : AppColors.grey300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: _isSaved ? AppColors.primary : AppColors.grey600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isSaved ? AppColors.primary : AppColors.grey600,
                    ),
                  ),
                ],
              ),
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

    // Simulate API call - replace with actual application logic later
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isApplying = false;
      });

      widget.onApply();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
