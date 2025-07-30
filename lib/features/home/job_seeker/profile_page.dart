// lib/features/auth/pages/home/job_seeker/profile_page_refactored.dart
// ignore_for_file: unused_result, deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final experiencesAsync = ref.watch(userExperiencesProvider);
    final skillsAsync = ref.watch(userSkillsProvider);
    final resumesAsync = ref.watch(userResumesProvider);
    final completion = ref.watch(profileCompletionProvider);
    final educationsAsync = ref.watch(userEducationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.refresh(userProfileProvider);
            ref.refresh(userExperiencesProvider);
            ref.refresh(userSkillsProvider);
            ref.refresh(userResumesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Settings Icon
                Row(
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.push('/seeker-settings'),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile Completion Card
                ProfileCompletionCard(completion: completion),
                const SizedBox(height: 20),

                // Profile Header Card
                profileAsync.when(
                  data: (profile) => ProfileHeaderCard(profile: profile),
                  loading: () => SharedWidgets.buildProfileHeaderLoading(),
                  error: (_, __) => SharedWidgets.buildProfileHeaderError(),
                ),
                const SizedBox(height: 20),

                // Resume Section
                resumesAsync.when(
                  data: (resumes) => ResumeSection(resumes: resumes),
                  loading: () => SharedWidgets.buildSectionLoading('Resume'),
                  error: (_, __) => SharedWidgets.buildSectionError('Resume'),
                ),
                const SizedBox(height: 20),

                // Experience Section
                experiencesAsync.when(
                  data: (experiences) =>
                      ExperienceSection(experiences: experiences),
                  loading: () =>
                      SharedWidgets.buildSectionLoading('Experience'),
                  error: (_, __) =>
                      SharedWidgets.buildSectionError('Experience'),
                ),
                const SizedBox(height: 20),

                // Skills Section
                skillsAsync.when(
                  data: (skills) => SkillsSection(skills: skills),
                  loading: () => SharedWidgets.buildSectionLoading('Skills'),
                  error: (_, __) => SharedWidgets.buildSectionError('Skills'),
                ),
                const SizedBox(height: 20),

                // Education Section
                educationsAsync.when(
                  data: (educations) =>
                      EducationSection(educations: educations),
                  loading: () => SharedWidgets.buildSectionLoading('Education'),
                  error: (_, __) =>
                      SharedWidgets.buildSectionError('Education'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
