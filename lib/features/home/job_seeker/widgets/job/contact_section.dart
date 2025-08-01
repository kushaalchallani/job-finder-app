import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/models/user_profile.dart';

class ContactSection extends ConsumerWidget {
  final JobOpening job;

  const ContactSection({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recruiterProfileAsync = ref.watch(
      recruiterProfileProvider(job.recruiterId),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
          _ContactHeader(),
          const SizedBox(height: 20),
          _ContactContent(recruiterProfileAsync: recruiterProfileAsync),
        ],
      ),
    );
  }
}

class _ContactHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ContactContent extends StatelessWidget {
  final AsyncValue<UserProfile?> recruiterProfileAsync;

  const _ContactContent({required this.recruiterProfileAsync});

  @override
  Widget build(BuildContext context) {
    return recruiterProfileAsync.when(
      data: (recruiterProfile) {
        if (recruiterProfile == null) {
          return _ContactCard.fallback();
        }
        return _ContactCard.recruiter(recruiterProfile);
      },
      loading: () => _ContactCard.loading(),
      error: (error, stack) => _ContactCard.fallback(),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final UserProfile? recruiterProfile;
  final bool isLoading;

  const _ContactCard({this.recruiterProfile, this.isLoading = false});

  factory _ContactCard.recruiter(UserProfile profile) {
    return _ContactCard(recruiterProfile: profile);
  }

  factory _ContactCard.fallback() {
    return const _ContactCard();
  }

  factory _ContactCard.loading() {
    return const _ContactCard(isLoading: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200, width: 1),
      ),
      child: Column(
        children: [
          _ProfileRow(recruiterProfile: recruiterProfile, isLoading: isLoading),
          const SizedBox(height: 16),
          _ContactInfo(
            recruiterProfile: recruiterProfile,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final UserProfile? recruiterProfile;
  final bool isLoading;

  const _ProfileRow({this.recruiterProfile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProfilePicture(
          recruiterProfile: recruiterProfile,
          isLoading: isLoading,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ProfileInfo(
            recruiterProfile: recruiterProfile,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  final UserProfile? recruiterProfile;
  final bool isLoading;

  const _ProfilePicture({this.recruiterProfile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(30),
        ),
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.profileGradientStart,
            AppColors.profileGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildProfileImage(),
    );
  }

  Widget _buildProfileImage() {
    if (recruiterProfile?.profileImageUrl != null &&
        recruiterProfile!.profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          recruiterProfile!.profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: AppColors.onPrimary, size: 28),
        ),
      );
    }
    return const Icon(Icons.person, color: AppColors.onPrimary, size: 28);
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserProfile? recruiterProfile;
  final bool isLoading;

  const _ProfileInfo({this.recruiterProfile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) ...[
          Container(
            height: 18,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ] else ...[
          Text(
            recruiterProfile?.fullName ?? 'Recruiter',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            recruiterProfile?.position ?? 'Recruiting Manager',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final UserProfile? recruiterProfile;
  final bool isLoading;

  const _ContactInfo({this.recruiterProfile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ContactRow(
          icon: Icons.email_outlined,
          iconColor: AppColors.primary,
          text: recruiterProfile?.email ?? 'recruiter@company.com',
          isLoading: isLoading,
        ),
        if (recruiterProfile?.phone != null &&
            recruiterProfile!.phone!.isNotEmpty &&
            !isLoading) ...[
          const SizedBox(height: 12),
          _ContactRow(
            icon: Icons.phone_outlined,
            iconColor: AppColors.success,
            text: recruiterProfile!.phone!,
            isLoading: false,
          ),
        ],
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final bool isLoading;

  const _ContactRow({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isLoading
              ? Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ],
    );
  }
}
