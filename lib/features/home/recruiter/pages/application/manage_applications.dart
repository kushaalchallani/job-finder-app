import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/application_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/manage_applications_error_state.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/manage_applications_list.dart';

class ManageApplicationsScreen extends ConsumerWidget {
  final String jobId;
  final JobOpening job;

  const ManageApplicationsScreen({
    Key? key,
    required this.jobId,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(jobApplicationsProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Applications - ${job.title}',
          style: const TextStyle(
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
      body: applicationsAsync.when(
        data: (applications) => ManageApplicationsList(
          applications: applications,
          jobId: jobId,
          onRefresh: () async {
            ref.invalidate(jobApplicationsProvider(jobId));
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            ManageApplicationsErrorState(error: error.toString()),
      ),
    );
  }
}
