import 'package:flutter/material.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/applications_filter_chips.dart';

class ApplicationsStatusFilterBar extends StatelessWidget {
  final String selectedStatus;
  final List<String> statusFilters;
  final ValueChanged<String> onStatusChanged;

  const ApplicationsStatusFilterBar({
    Key? key,
    required this.selectedStatus,
    required this.statusFilters,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ApplicationsFilterChips(
      selectedStatus: selectedStatus,
      statusFilters: statusFilters,
      onStatusChanged: onStatusChanged,
    );
  }
}
