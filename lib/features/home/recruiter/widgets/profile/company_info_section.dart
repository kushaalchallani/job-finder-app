import 'package:flutter/material.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class CompanyInfoSection extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController positionController;

  const CompanyInfoSection({
    required this.companyNameController,
    required this.positionController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AuthTextField(controller: companyNameController, label: 'Company Name'),
        const SizedBox(height: 16),
        AuthTextField(controller: positionController, label: 'Position/Title'),
        const SizedBox(height: 32),
      ],
    );
  }
}
