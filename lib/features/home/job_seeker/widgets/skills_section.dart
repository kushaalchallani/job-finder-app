// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/shared/shared_widgets.dart';
import 'package:job_finder_app/models/user_profile.dart';

class SkillsSection extends StatelessWidget {
  final List<UserSkill> skills;

  // ignore: use_super_parameters
  const SkillsSection({Key? key, required this.skills}) : super(key: key);

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
                'Skills',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push('/edit-skills'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (skills.isEmpty)
            SharedWidgets.buildEmptyState(
              'No skills added yet',
              'Add your skills to help recruiters find you',
              Icons.star_outline,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(UserSkill skill) {
    Color chipColor;
    switch (skill.proficiencyLevel) {
      case 'beginner':
        chipColor = AppColors.warning;
        break;
      case 'intermediate':
        chipColor = AppColors.info;
        break;
      case 'advanced':
        chipColor = AppColors.success;
        break;
      case 'expert':
        chipColor = AppColors.primary;
        break;
      default:
        chipColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        skill.skillName,
        style: TextStyle(
          fontSize: 14,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
