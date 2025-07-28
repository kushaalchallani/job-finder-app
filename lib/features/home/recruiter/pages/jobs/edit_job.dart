// lib/screens/recruiter/edit_job_screen.dart
// ignore_for_file: deprecated_member_use, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/job_form_sections.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/job/job_update_helpers.dart';

class EditJobScreen extends ConsumerStatefulWidget {
  final JobOpening job;

  const EditJobScreen({Key? key, required this.job}) : super(key: key);

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
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
    // Pre-populate form with existing job data
    _titleController.text = widget.job.title;
    _companyController.text = widget.job.companyName;
    _locationController.text = widget.job.location;
    _descriptionController.text = widget.job.description;
    _salaryRangeController.text = widget.job.salaryRange ?? '';
    _requirements = List<String>.from(widget.job.requirements);
    _benefits = List<String>.from(widget.job.benefits);
    _selectedJobType = widget.job.jobType;
    _selectedExperienceLevel = widget.job.experienceLevel;
    _selectedStatus = widget.job.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Job: ${widget.job.title}',
          style: const TextStyle(
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
              BasicInformationSection(
                titleController: _titleController,
                companyController: _companyController,
                locationController: _locationController,
              ),
              const SizedBox(height: 20),
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
              JobDescriptionSection(
                descriptionController: _descriptionController,
              ),
              const SizedBox(height: 20),
              RequirementsSection(
                requirementController: _requirementController,
                requirements: _requirements,
                onAddRequirement: _addRequirement,
                onRemoveRequirement: _removeRequirement,
              ),
              const SizedBox(height: 20),
              BenefitsSection(
                benefitController: _benefitController,
                benefits: _benefits,
                onAddBenefit: _addBenefit,
                onRemoveBenefit: _removeBenefit,
              ),
              const SizedBox(height: 32),
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
        text: 'Update Job',
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _updateJob(status: _selectedStatus);
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
    await _updateJob(status: 'paused');
  }

  Future<void> _updateJob({required String status}) async {
    final jobData = JobUpdateData(
      id: widget.job.id,
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

    await updateJob(
      jobData: jobData,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'paused'
                  ? 'Job saved as draft!'
                  : 'Job updated successfully!',
            ),
            backgroundColor: const Color(0xFF50C878),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating job: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onLoading: () => setState(() => _isLoading = true),
      onLoadingComplete: () => setState(() => _isLoading = false),
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
