import 'package:flutter/material.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class PersonalInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController locationController;

  const PersonalInfoSection({
    required this.nameController,
    required this.phoneController,
    required this.locationController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AuthTextField(controller: nameController, label: 'Full Name'),
        const SizedBox(height: 16),
        AuthTextField(
          controller: phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AuthTextField(controller: locationController, label: 'Location'),
        const SizedBox(height: 32),
      ],
    );
  }
}
