import 'package:flutter/material.dart';
import 'package:job_finder_app/models/user_profile.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class RecruiterDashboardProfile extends StatelessWidget {
  final UserProfile? userProfile;
  const RecruiterDashboardProfile({Key? key, required this.userProfile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  AppColors.profileGradientStart,
                  AppColors.profileGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: userProfile?.profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      userProfile!.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: AppColors.onPrimary,
                        size: 28,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: AppColors.onPrimary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile?.fullName ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.role == 'recruiter' ? 'Recruiter' : 'User',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                if (userProfile?.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userProfile!.location!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey600,
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
