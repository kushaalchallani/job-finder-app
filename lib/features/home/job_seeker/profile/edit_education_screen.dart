// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/widgets/button.dart';

class EditEducationScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const EditEducationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditEducationScreen> createState() =>
      _EditEducationScreenState();
}

class _EditEducationScreenState extends ConsumerState<EditEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _gpaController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  Future<void> _addEducation() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('user_education').insert({
        'user_id': user.id,
        'institution': _institutionController.text.trim(),
        'degree': _degreeController.text.trim(),
        'field_of_study': _fieldController.text.trim(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _isCurrent ? null : _endDate?.toIso8601String(),
        'gpa': _gpaController.text.trim(),
        'description': _descController.text.trim(),
        // Add is_current if your schema supports it
      });
      ref.refresh(userEducationProvider);
      _institutionController.clear();
      _degreeController.clear();
      _fieldController.clear();
      _gpaController.clear();
      _descController.clear();
      _isCurrent = false;
      _startDate = null;
      _endDate = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEducation(String eduId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('user_education').delete().eq('id', eduId);
      ref.refresh(userEducationProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(DateTime.now().year - 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (res != null) setState(() => _startDate = res);
  }

  Future<void> _pickEndDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (res != null) setState(() => _endDate = res);
  }

  @override
  Widget build(BuildContext context) {
    final eduAsync = ref.watch(userEducationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Education'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    controller: _institutionController,
                    label: 'Institution (School/College)',
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: _degreeController,
                    label: 'Degree (e.g. B.Sc, M.Tech)',
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: _fieldController,
                    label: 'Field of Study',
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: _gpaController,
                    label: 'GPA (optional)',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickStartDate,
                          child: Text(
                            _startDate == null
                                ? 'Start Date'
                                : 'Start: ${_startDate!.month}/${_startDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isCurrent ? null : _pickEndDate,
                          child: Text(
                            _isCurrent
                                ? 'Currently Studying'
                                : (_endDate == null
                                      ? 'End Date'
                                      : 'End: ${_endDate!.month}/${_endDate!.year}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isCurrent,
                        onChanged: (val) {
                          setState(() {
                            _isCurrent = val ?? false;
                            if (_isCurrent) _endDate = null;
                          });
                        },
                      ),
                      const Text('Currently studying here'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AuthTextField(
                    controller: _descController,
                    label: 'Description (optional)',
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: 'Add Education',
                    onPressed: _addEducation,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Education:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            eduAsync.when(
              data: (items) => items.isEmpty
                  ? const Text(
                      "No education added yet.",
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : Column(
                      children: items
                          .map(
                            (e) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(
                                  '${e.degree ?? ''}${e.fieldOfStudy != null && e.fieldOfStudy!.isNotEmpty ? ' in ${e.fieldOfStudy}' : ''}',
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.institution ?? '',
                                      style: TextStyle(
                                        color: AppColors.grey700,
                                      ),
                                    ),
                                    Text(
                                      '${e.startDate.month}/${e.startDate.year} - '
                                      '${e.endDate != null ? "${e.endDate!.month}/${e.endDate!.year}" : "Present"}'
                                      '${e.gpa != null && e.gpa!.isNotEmpty ? ' | GPA: ${e.gpa}' : ''}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey500,
                                      ),
                                    ),
                                    if (e.description != null &&
                                        e.description!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          e.description!,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteEducation(e.id),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                e.toString(),
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
