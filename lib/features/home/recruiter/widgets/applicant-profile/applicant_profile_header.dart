import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class ApplicantProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String fallbackName;

  const ApplicantProfileHeader({
    Key? key,
    required this.profile,
    required this.fallbackName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage:
                (profile['profile_image_url'] != null &&
                    (profile['profile_image_url'] as String).isNotEmpty)
                ? NetworkImage(profile['profile_image_url'])
                : null,
            child:
                (profile['profile_image_url'] == null ||
                    (profile['profile_image_url'] as String).isEmpty)
                ? Text(
                    (profile['full_name'] ?? fallbackName).isNotEmpty
                        ? (profile['full_name'] ?? fallbackName)[0]
                              .toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['full_name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['job_title'] ?? 'Unknown Job',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile['location'] != null &&
                    profile['location'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile['location'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
