// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/shared/shared_widgets.dart';
import 'package:job_finder_app/models/user_profile.dart';

class ExperienceSection extends StatelessWidget {
  final List<UserExperience> experiences;

  // ignore: use_super_parameters
  const ExperienceSection({Key? key, required this.experiences})
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
                'Experience',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push('/edit-experience'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (experiences.isEmpty)
            SharedWidgets.buildEmptyState(
              'No experience added yet',
              'Add your work experience to showcase your background',
              Icons.work_outline,
            )
          else
            // ignore: unnecessary_to_list_in_spreads
            ...experiences.map((exp) => _buildExperienceItem(exp)).toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(UserExperience experience) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.jobTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  experience.companyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(experience.startDate)} - ${experience.isCurrent ? "Present" : _formatDate(experience.endDate!)}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                if (experience.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    experience.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey700,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
