import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/manage_application_card.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/manage_applications_empty_state.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/manage_applications_helpers.dart';
import 'package:job_finder_app/features/home/recruiter/pages/application/applicant_profile_screen.dart';

class ManageApplicationsList extends ConsumerWidget {
  final List applications;
  final String jobId;
  final Future<void> Function() onRefresh;

  const ManageApplicationsList({
    Key? key,
    required this.applications,
    required this.jobId,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (applications.isEmpty) {
      return const ManageApplicationsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          return ManageApplicationCard(
            application: application,
            jobId: jobId,
            onViewDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ApplicantProfileScreen(application: application),
                ),
              );
            },
            onUpdateStatus: () =>
                updateApplicationStatus(context, application, jobId, ref),
          );
        },
      ),
    );
  }
}
