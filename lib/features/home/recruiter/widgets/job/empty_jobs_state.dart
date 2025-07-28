import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class EmptyJobsState extends StatelessWidget {
  const EmptyJobsState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new job to get started!',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
