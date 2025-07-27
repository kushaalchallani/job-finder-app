import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';

class BenefitsSection extends StatelessWidget {
  final JobOpening job;

  const BenefitsSection({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create benefits list from job data
    List<Map<String, dynamic>> benefitItems = [];

    // Add salary if available
    if (job.salaryRange != null) {
      benefitItems.add({'icon': Icons.attach_money, 'title': job.salaryRange});
    }

    // Add job type
    benefitItems.add({
      'icon': Icons.work_outline,
      'title': '${job.jobType.replaceAll('-', ' ').toUpperCase()} Job',
    });

    // Add experience level
    benefitItems.add({
      'icon': Icons.trending_up,
      'title': '${job.experienceLevel.toUpperCase()} Level',
    });

    // Add benefits from job data
    for (String benefit in job.benefits.take(2)) {
      IconData icon;
      if (benefit.toLowerCase().contains('health')) {
        icon = Icons.local_hospital_outlined;
      } else if (benefit.toLowerCase().contains('time off') ||
          benefit.toLowerCase().contains('vacation')) {
        icon = Icons.schedule_outlined;
      } else if (benefit.toLowerCase().contains('remote')) {
        icon = Icons.home_work_outlined;
      } else {
        icon = Icons.star_outline;
      }

      benefitItems.add({'icon': icon, 'title': benefit});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefitItems
          .map(
            (benefit) => Container(
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      benefit['icon'],
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
