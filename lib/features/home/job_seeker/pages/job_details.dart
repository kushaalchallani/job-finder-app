// lib/features/auth/pages/home/job_seeker/job_details_refactored.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/job/job.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;

  // ignore: use_super_parameters
  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailsProvider(widget.jobId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return JobErrorStates.buildJobNotFound(context);
          }
          return _buildJobDetails(job);
        },
        loading: () => JobErrorStates.buildLoading(),
        error: (error, stack) => JobErrorStates.buildError(
          error,
          () => ref.refresh(jobDetailsProvider(widget.jobId)),
        ),
      ),
    );
  }

  Widget _buildJobDetails(JobOpening job) {
    return Column(
      children: [
        // Enhanced Header with Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.brandBlue],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.onPrimary,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Job Details',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Company Info Card in Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: CompanyInfoCard(job: job),
                ),
              ],
            ),
          ),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title with Salary
                JobTitleSection(job: job),
                const SizedBox(height: 24),

                // Key Details Row
                _buildKeyDetailsRow(job),
                const SizedBox(height: 24),

                // Benefits Section
                BenefitsSection(job: job),
                const SizedBox(height: 24),

                // Job Description
                JobDescriptionSection(job: job),
                const SizedBox(height: 24),

                // Requirements
                if (job.requirements.isNotEmpty) ...[
                  RequirementsSection(job: job),
                  const SizedBox(height: 24),
                ],

                // Contact Section
                ContactSection(job: job),
                const SizedBox(height: 8), // Minimal spacing
              ],
            ),
          ),
        ),

        // Bottom Action Buttons
        JobActions(
          job: job,
          onApply: () {
            // Handle successful application
          },
        ),
      ],
    );
  }

  Widget _buildKeyDetailsRow(JobOpening job) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _buildDetailItem(
              icon: Icons.work_outline,
              title: 'Job Type',
              value: job.jobType.replaceAll('-', ' ').toUpperCase(),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.grey200),
          Expanded(
            child: _buildDetailItem(
              icon: Icons.trending_up,
              title: 'Experience',
              value: job.experienceLevel.toUpperCase(),
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.grey200),
          Expanded(
            child: _buildDetailItem(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: job.location,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
