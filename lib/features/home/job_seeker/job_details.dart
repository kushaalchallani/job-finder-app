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
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
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
        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Info Card
                CompanyInfoCard(job: job),
                const SizedBox(height: 20),

                // Job Title
                JobTitleSection(job: job),
                const SizedBox(height: 20),

                // Benefits Section
                BenefitsSection(job: job),
                const SizedBox(height: 20),

                // Job Description
                JobDescriptionSection(job: job),
                const SizedBox(height: 20),

                // Requirements
                if (job.requirements.isNotEmpty) ...[
                  RequirementsSection(job: job),
                  const SizedBox(height: 20),
                ],

                // Contact Section
                ContactSection(job: job),
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
}
