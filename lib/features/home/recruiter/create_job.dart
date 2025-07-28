// lib/screens/recruiter/create_job_screen.dart
// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/widgets/button.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const CreateJobScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryRangeController = TextEditingController(); // Fixed naming
  final _requirementController = TextEditingController();
  final _benefitController = TextEditingController();

  String _selectedJobType = 'full-time';
  String _selectedExperienceLevel = 'mid';
  String _selectedStatus = 'active'; // Added status field
  List<String> _requirements = [];
  List<String> _benefits = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Job Opening',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,

        actions: [
          // Added Save Draft functionality
          TextButton(
            onPressed: _isLoading ? null : _saveDraft,
            child: Text(
              'Save Draft',
              style: TextStyle(
                color: _isLoading ? AppColors.textSecondary : AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionCard('Basic Information', [
                _buildInputField(
                  'Job Title',
                  _titleController,
                  'e.g., Software Engineer',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Company Name',
                  _companyController,
                  'e.g., Tech Corp',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Location',
                  _locationController,
                  'e.g., New York, NY',
                  required: true,
                ),
              ]),
              const SizedBox(height: 20),

              // Job Details Section
              _buildSectionCard('Job Details', [
                // Made Job Type and Experience Level side by side
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Job Type',
                        _selectedJobType,
                        [
                          {'value': 'full-time', 'label': 'Full-time'},
                          {'value': 'part-time', 'label': 'Part-time'},
                          {'value': 'remote', 'label': 'Remote'},
                          {'value': 'contract', 'label': 'Contract'},
                        ],
                        (value) => setState(() => _selectedJobType = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        'Experience Level',
                        _selectedExperienceLevel,
                        [
                          {'value': 'entry', 'label': 'Entry Level'},
                          {'value': 'mid', 'label': 'Mid Level'},
                          {'value': 'senior', 'label': 'Senior Level'},
                          {'value': 'executive', 'label': 'Executive'},
                        ],
                        (value) =>
                            setState(() => _selectedExperienceLevel = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Salary Range',
                  _salaryRangeController, // Fixed controller name
                  'e.g., \$50,000 - \$70,000',
                ),
                const SizedBox(height: 16),
                // Added Status dropdown
                _buildDropdownField(
                  'Status',
                  _selectedStatus,
                  [
                    {'value': 'active', 'label': 'Active'},
                    {'value': 'paused', 'label': 'Paused'},
                    {'value': 'closed', 'label': 'Closed'},
                  ],
                  (value) => setState(() => _selectedStatus = value!),
                ),
              ]),
              const SizedBox(height: 20),

              // Job Description Section
              _buildSectionCard('Job Description', [
                _buildInputField(
                  'Description',
                  _descriptionController,
                  'Describe the role, responsibilities, and what the candidate will be doing...',
                  maxLines: 6,
                  required: true,
                ),
              ]),
              const SizedBox(height: 20),

              // Requirements Section
              _buildSectionCard('Requirements', [
                _buildChipInputField(
                  'Add Requirement',
                  _requirementController,
                  _requirements,
                  _addRequirement,
                  _removeRequirement,
                  'e.g., 3+ years experience with React',
                ),
              ]),
              const SizedBox(height: 20),

              // Benefits Section
              _buildSectionCard('Benefits', [
                _buildChipInputField(
                  'Add Benefit',
                  _benefitController,
                  _benefits,
                  _addBenefit,
                  _removeBenefit,
                  'e.g., Health insurance, Remote work',
                ),
              ]),
              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
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
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
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
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
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
            onChanged: onChanged,
          ),
        ),
      ],
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
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: AuthTextField(controller: controller, label: hint),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.white),
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
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF4A90E2).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => onRemove(item),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF4A90E2),
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

  Widget _buildSubmitButton() {
    return PrimaryButton(
      text: 'Create Job Opening',
      onPressed: _submitJob,
      isLoading: _isLoading,
    );
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text.trim());
        _requirementController.clear();
      });
    }
  }

  void _removeRequirement(String requirement) {
    setState(() {
      _requirements.remove(requirement);
    });
  }

  void _addBenefit() {
    if (_benefitController.text.trim().isNotEmpty) {
      setState(() {
        _benefits.add(_benefitController.text.trim());
        _benefitController.clear();
      });
    }
  }

  void _removeBenefit(String benefit) {
    setState(() {
      _benefits.remove(benefit);
    });
  }

  // Added Save Draft functionality
  void _saveDraft() async {
    await _createJob(status: 'paused');
  }

  void _submitJob() async {
    if (_formKey.currentState!.validate()) {
      await _createJob(status: _selectedStatus);
    }
  }

  // Refactored job creation logic
  Future<void> _createJob({required String status}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final jobData = {
        'recruiter_id': user.id,
        'title': _titleController.text.trim(),
        'company_name': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'job_type': _selectedJobType,
        'experience_level': _selectedExperienceLevel,
        'description': _descriptionController.text.trim(),
        'salary_range': _salaryRangeController.text.trim().isEmpty
            ? null
            : _salaryRangeController.text.trim(),
        'requirements': _requirements,
        'benefits': _benefits,
        'status': status, // Added status field
      };

      await supabase.from('job_openings').insert(jobData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'paused'
                  ? 'Job saved as draft!'
                  : 'Job created successfully!',
            ),
            backgroundColor: const Color(0xFF50C878),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear form after successful submission
        _clearForm();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating job: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Added form clearing functionality
  void _clearForm() {
    _titleController.clear();
    _companyController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _salaryRangeController.clear();
    _requirementController.clear();
    _benefitController.clear();
    setState(() {
      _requirements.clear();
      _benefits.clear();
      _selectedJobType = 'full-time';
      _selectedExperienceLevel = 'mid';
      _selectedStatus = 'active';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryRangeController.dispose(); // Fixed controller name
    _requirementController.dispose();
    _benefitController.dispose();
    super.dispose();
  }
}
