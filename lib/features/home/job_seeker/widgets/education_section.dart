// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/shared/shared_widgets.dart';
import 'package:job_finder_app/models/user_profile.dart';

class EducationSection extends StatelessWidget {
  final List<UserEducation> educations;

  // ignore: use_super_parameters
  const EducationSection({Key? key, required this.educations})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Education',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => context.push('/edit-education'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (educations.isEmpty)
            SharedWidgets.buildEmptyState(
              'No education data yet',
              'Add your education credentials here.',
              Icons.school_outlined,
            )
          else
            // ignore: unnecessary_to_list_in_spreads
            ...educations.map((e) => _buildEducationItem(e)).toList(),
        ],
      ),
    );
  }

  Widget _buildEducationItem(UserEducation edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            edu.degree != null && edu.degree!.isNotEmpty
                ? '${edu.degree}${edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty ? ' in ${edu.fieldOfStudy}' : ''}'
                : (edu.fieldOfStudy ?? ''),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            edu.institution ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
          const SizedBox(height: 2),
          Text(
            '${edu.startDate.month}/${edu.startDate.year} - '
            '${edu.endDate != null ? '${edu.endDate!.month}/${edu.endDate!.year}' : 'Present'}'
            '${edu.gpa != null && edu.gpa!.isNotEmpty ? ' | GPA: ${edu.gpa}' : ''}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          if (edu.description != null && edu.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                edu.description!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
