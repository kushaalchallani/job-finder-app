// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/job_form_sections.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/job_creation_helpers.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
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
  final _salaryRangeController = TextEditingController();
  final _requirementController = TextEditingController();
  final _benefitController = TextEditingController();

  String _selectedJobType = 'full-time';
  String _selectedExperienceLevel = 'mid';
  String _selectedStatus = 'active';
  List<String> _requirements = [];
  List<String> _benefits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill company name from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.whenData((userProfile) {
        if (userProfile?.company != null && userProfile!.company!.isNotEmpty) {
          setState(() {
            _companyController.text = userProfile.company!;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create New Job',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
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
              BasicInformationSection(
                titleController: _titleController,
                companyController: _companyController,
                locationController: _locationController,
              ),
              const SizedBox(height: 20),

              // Job Details Section
              JobDetailsSection(
                selectedJobType: _selectedJobType,
                selectedExperienceLevel: _selectedExperienceLevel,
                selectedStatus: _selectedStatus,
                salaryRangeController: _salaryRangeController,
                onJobTypeChanged: (value) =>
                    setState(() => _selectedJobType = value),
                onExperienceLevelChanged: (value) =>
                    setState(() => _selectedExperienceLevel = value),
                onStatusChanged: (value) =>
                    setState(() => _selectedStatus = value),
              ),
              const SizedBox(height: 20),

              // Job Description Section
              JobDescriptionSection(
                descriptionController: _descriptionController,
              ),
              const SizedBox(height: 20),

              // Requirements Section
              RequirementsSection(
                requirementController: _requirementController,
                requirements: _requirements,
                onAddRequirement: _addRequirement,
                onRemoveRequirement: _removeRequirement,
              ),
              const SizedBox(height: 20),

              // Benefits Section
              BenefitsSection(
                benefitController: _benefitController,
                benefits: _benefits,
                onAddBenefit: _addBenefit,
                onRemoveBenefit: _removeBenefit,
              ),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Create Job',
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _createJob(status: _selectedStatus);
          }
        },
        isLoading: _isLoading,
      ),
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

  void _saveDraft() async {
    await _createJob(status: 'paused');
  }

  Future<void> _createJob({required String status}) async {
    final jobData = JobCreationData(
      title: _titleController.text.trim(),
      companyName: _companyController.text.trim(),
      location: _locationController.text.trim(),
      jobType: _selectedJobType,
      experienceLevel: _selectedExperienceLevel,
      description: _descriptionController.text.trim(),
      salaryRange: _salaryRangeController.text.trim().isEmpty
          ? null
          : _salaryRangeController.text.trim(),
      requirements: _requirements,
      benefits: _benefits,
      status: status,
    );

    await createJob(
      jobData: jobData,
      onSuccess: () {
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
        _clearForm();
        context.pop();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating job: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLoading: () => setState(() => _isLoading = true),
      onLoadingComplete: () => setState(() => _isLoading = false),
    );
  }

  void _clearForm() {
    clearJobForm(
      titleController: _titleController,
      companyController: _companyController,
      locationController: _locationController,
      descriptionController: _descriptionController,
      salaryRangeController: _salaryRangeController,
      requirementController: _requirementController,
      benefitController: _benefitController,
      onStateChanged: () {
        setState(() {
          _requirements.clear();
          _benefits.clear();
          _selectedJobType = 'full-time';
          _selectedExperienceLevel = 'mid';
          _selectedStatus = 'active';
        });
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryRangeController.dispose();
    _requirementController.dispose();
    _benefitController.dispose();
    super.dispose();
  }
}
