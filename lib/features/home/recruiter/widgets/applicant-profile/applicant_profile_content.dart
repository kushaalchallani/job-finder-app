import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/applicant-profile/applicant_profile_header.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/applicant-profile/applicant_profile_sections.dart';

class ApplicantProfileContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final JobApplication application;
  final VoidCallback onUpdateStatus;

  const ApplicantProfileContent({
    Key? key,
    required this.data,
    required this.application,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = data['profile'] as Map<String, dynamic>;
    final experience = data['experience'] as List;
    final education = data['education'] as List;
    final skills = data['skills'] as List;
    final resume = data['resume'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          ApplicantProfileHeader(
            profile: profile,
            fallbackName: application.userFullName,
          ),
          const SizedBox(height: 24),

          // Application Status Section
          ApplicationStatusSection(application: application),
          const SizedBox(height: 24),

          // Bio Section (if available)
          if (profile['bio'] != null &&
              profile['bio'].toString().isNotEmpty &&
              profile['bio'].toString() != 'No bio available') ...[
            BioSection(bio: profile['bio']),
            const SizedBox(height: 24),
          ],

          // Contact Information
          ContactSection(
            profile: profile,
            fallbackEmail: application.userEmail,
          ),
          const SizedBox(height: 24),

          // Resume Section
          if (resume != null) ...[
            ResumeSection(resume: resume),
            const SizedBox(height: 24),
          ] else ...[
            const NoResumeSection(),
            const SizedBox(height: 24),
          ],

          // Experience Section
          if (experience.isNotEmpty) ...[
            ExperienceSection(experience: experience),
            const SizedBox(height: 24),
          ] else ...[
            const NoExperienceSection(),
            const SizedBox(height: 24),
          ],

          // Education Section
          if (education.isNotEmpty) ...[
            EducationSection(education: education),
            const SizedBox(height: 24),
          ] else ...[
            const NoEducationSection(),
            const SizedBox(height: 24),
          ],

          // Skills Section
          if (skills.isNotEmpty) ...[
            SkillsSection(skills: skills),
            const SizedBox(height: 24),
          ] else ...[
            const NoSkillsSection(),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onUpdateStatus,
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Update Status'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
