// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class BasicInformationSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController companyController;
  final TextEditingController locationController;

  const BasicInformationSection({
    Key? key,
    required this.titleController,
    required this.companyController,
    required this.locationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard('Basic Information', [
      _buildInputField(
        'Job Title',
        titleController,
        'e.g., Software Engineer',
        required: true,
      ),
      const SizedBox(height: 16),
      _buildInputField(
        'Company Name',
        companyController,
        'e.g., Tech Corp',
        required: true,
      ),
      const SizedBox(height: 16),
      _buildInputField(
        'Location',
        locationController,
        'e.g., New York, NY',
        required: true,
      ),
    ]);
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: AuthTextField(controller: controller, label: hint),
        ),
      ],
    );
  }
}

class JobDetailsSection extends StatelessWidget {
  final String selectedJobType;
  final String selectedExperienceLevel;
  final String selectedStatus;
  final TextEditingController salaryRangeController;
  final ValueChanged<String> onJobTypeChanged;
  final ValueChanged<String> onExperienceLevelChanged;
  final ValueChanged<String> onStatusChanged;

  const JobDetailsSection({
    Key? key,
    required this.selectedJobType,
    required this.selectedExperienceLevel,
    required this.selectedStatus,
    required this.salaryRangeController,
    required this.onJobTypeChanged,
    required this.onExperienceLevelChanged,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard('Job Details', [
      Row(
        children: [
          Expanded(
            child: _buildDropdownField('Job Type', selectedJobType, [
              {'value': 'full-time', 'label': 'Full-time'},
              {'value': 'part-time', 'label': 'Part-time'},
              {'value': 'remote', 'label': 'Remote'},
              {'value': 'contract', 'label': 'Contract'},
            ], onJobTypeChanged),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdownField(
              'Experience Level',
              selectedExperienceLevel,
              [
                {'value': 'entry', 'label': 'Entry Level'},
                {'value': 'mid', 'label': 'Mid Level'},
                {'value': 'senior', 'label': 'Senior Level'},
                {'value': 'executive', 'label': 'Executive'},
              ],
              onExperienceLevelChanged,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildInputField(
        'Salary Range',
        salaryRangeController,
        'e.g., \$50,000 - \$70,000',
      ),
      const SizedBox(height: 16),
      _buildDropdownField('Status', selectedStatus, [
        {'value': 'active', 'label': 'Active'},
        {'value': 'paused', 'label': 'Paused'},
        {'value': 'closed', 'label': 'Closed'},
      ], onStatusChanged),
    ]);
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: AuthTextField(controller: controller, label: hint),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<Map<String, String>> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option['value'],
                    child: Text(
                      option['label']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => onChanged(value!),
          ),
        ),
      ],
    );
  }
}

class JobDescriptionSection extends StatelessWidget {
  final TextEditingController descriptionController;

  const JobDescriptionSection({Key? key, required this.descriptionController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard('Job Description', [
      _buildInputField(
        'Description',
        descriptionController,
        'Describe the role, responsibilities, and what the candidate will be doing...',
        maxLines: 6,
        required: true,
      ),
    ]);
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: AuthTextField(controller: controller, label: hint),
        ),
      ],
    );
  }
}

class RequirementsSection extends StatelessWidget {
  final TextEditingController requirementController;
  final List<String> requirements;
  final VoidCallback onAddRequirement;
  final Function(String) onRemoveRequirement;

  const RequirementsSection({
    Key? key,
    required this.requirementController,
    required this.requirements,
    required this.onAddRequirement,
    required this.onRemoveRequirement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard('Requirements', [
      _buildChipInputField(
        'Add Requirement',
        requirementController,
        requirements,
        onAddRequirement,
        onRemoveRequirement,
        'e.g., 3+ years experience with React',
      ),
    ]);
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChipInputField(
    String label,
    TextEditingController controller,
    List<String> items,
    VoidCallback onAdd,
    Function(String) onRemove,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: AuthTextField(controller: controller, label: hint),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class BenefitsSection extends StatelessWidget {
  final TextEditingController benefitController;
  final List<String> benefits;
  final VoidCallback onAddBenefit;
  final Function(String) onRemoveBenefit;

  const BenefitsSection({
    Key? key,
    required this.benefitController,
    required this.benefits,
    required this.onAddBenefit,
    required this.onRemoveBenefit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard('Benefits', [
      _buildChipInputField(
        'Add Benefit',
        benefitController,
        benefits,
        onAddBenefit,
        onRemoveBenefit,
        'e.g., Health insurance, Remote work',
      ),
    ]);
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildChipInputField(
    String label,
    TextEditingController controller,
    List<String> items,
    VoidCallback onAdd,
    Function(String) onRemove,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: AuthTextField(controller: controller, label: hint),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
