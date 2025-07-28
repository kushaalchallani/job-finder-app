import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class ApplicationsFilterChips extends StatelessWidget {
  final String selectedStatus;
  final List<String> statusFilters;
  final ValueChanged<String> onStatusChanged;

  const ApplicationsFilterChips({
    Key? key,
    required this.selectedStatus,
    required this.statusFilters,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusFilters.map((status) {
            return Row(
              children: [
                FilterChip(
                  label: Text(_capitalize(status)),
                  selected: selectedStatus == status,
                  onSelected: (selected) {
                    if (selected) onStatusChanged(status);
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selectedStatus == status
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: selectedStatus == status
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}
