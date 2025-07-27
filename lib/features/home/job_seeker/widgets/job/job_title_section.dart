import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';

class JobTitleSection extends StatelessWidget {
  final JobOpening job;

  const JobTitleSection({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      job.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
