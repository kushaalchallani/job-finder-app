import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class RecentApplications extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentApplications({Key? key, this.onViewAll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Applications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        // Still using dummy data for now - you can replace this when you add applications
        _buildApplicationItem(
          'Software Engineer',
          'Google',
          'Under Review',
          AppColors.warning,
        ),
        _buildApplicationItem(
          'Product Manager',
          'Apple',
          'Interview',
          AppColors.success,
        ),
        _buildApplicationItem(
          'UI Designer',
          'Microsoft',
          'Applied',
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildApplicationItem(
    String title,
    String company,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: AppColors.grey600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  company,
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
