// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';

class EditExperienceScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const EditExperienceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditExperienceScreen> createState() =>
      _EditExperienceScreenState();
}

class _EditExperienceScreenState extends ConsumerState<EditExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  Future<void> _addExperience() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('user_experiences').insert({
        'user_id': user.id,
        'job_title': _jobTitleController.text.trim(),
        'company_name': _companyController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _isCurrent ? null : _endDate?.toIso8601String(),
        'is_current': _isCurrent,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      });
      ref.refresh(userExperiencesProvider);
      _jobTitleController.clear();
      _companyController.clear();
      _locationController.clear();
      _descriptionController.clear();
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

  Future<void> _deleteExperience(String expId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('user_experiences').delete().eq('id', expId);
      ref.refresh(userExperiencesProvider);
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
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (res != null) {
      setState(() => _startDate = res);
    }
  }

  Future<void> _pickEndDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (res != null) {
      setState(() => _endDate = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expAsync = ref.watch(userExperiencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Experience'),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[50],
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
                  TextFormField(
                    controller: _jobTitleController,
                    decoration: const InputDecoration(labelText: 'Job Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                    ),
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
                                ? 'Present'
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
                      const Text('I currently work here'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addExperience,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Experience'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Experience:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            expAsync.when(
              data: (items) => items.isEmpty
                  ? const Text(
                      "No experience added yet.",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      children: items
                          .map(
                            (e) => Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                title: Text('${e.jobTitle} - ${e.companyName}'),
                                subtitle: Text(
                                  '${e.startDate.month}/${e.startDate.year} - ${e.isCurrent ? "Present" : "${e.endDate?.month}/${e.endDate?.year}"}\n${e.description ?? ""}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteExperience(e.id),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Text(e.toString(), style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
