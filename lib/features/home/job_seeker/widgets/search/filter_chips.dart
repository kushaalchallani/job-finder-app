import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const FilterChips({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'value': 'All', 'display': 'All'},
      {'value': 'full-time', 'display': 'FULL TIME'},
      {'value': 'part-time', 'display': 'PART TIME'},
      {'value': 'remote', 'display': 'REMOTE'},
      {'value': 'contract', 'display': 'CONTRACT'},
    ];

    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['value'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter['value']!),
              child: Container(
                constraints: const BoxConstraints(minWidth: 80, minHeight: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey300,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter['display']!,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.grey700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
