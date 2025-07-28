import 'package:flutter/material.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/applications_empty_state.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/recruiter_application_card.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/recruiter_applications_helpers.dart';

class RecruiterApplicationsList extends StatelessWidget {
  final List applications;
  final String selectedStatus;
  final String? selectedJobId;
  final Future<void> Function() onRefresh;

  const RecruiterApplicationsList({
    Key? key,
    required this.applications,
    required this.selectedStatus,
    required this.selectedJobId,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Apply filters
    var filteredApplications = applications;
    if (selectedStatus != 'All') {
      filteredApplications = applications
          .where((app) => app.status == selectedStatus)
          .toList();
    }
    if (selectedJobId != null) {
      filteredApplications = filteredApplications
          .where((app) => app.jobId == selectedJobId)
          .toList();
    }
    if (filteredApplications.isEmpty) {
      return const ApplicationsEmptyState();
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredApplications.length,
        itemBuilder: (context, index) {
          final application = filteredApplications[index];
          return RecruiterApplicationCard(
            application: application,
            onViewProfile: () => viewApplicantProfile(context, application),
            onUpdateStatus: () => updateApplicationStatus(context, application),
          );
        },
      ),
    );
  }
}
