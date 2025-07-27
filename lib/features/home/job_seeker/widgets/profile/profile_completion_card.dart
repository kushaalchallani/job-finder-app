import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class ProfileCompletionCard extends StatelessWidget {
  final double completion;

  // ignore: use_super_parameters
  const ProfileCompletionCard({Key? key, required this.completion})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                'Profile Completion',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(completion * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completion,
            backgroundColor: AppColors.grey200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            completion >= 1.0
                ? 'Your profile is complete! 🎉'
                : 'Complete your profile to increase your chances of getting hired',
            style: TextStyle(fontSize: 14, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
