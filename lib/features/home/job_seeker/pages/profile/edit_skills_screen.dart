// ignore_for_file: unused_result, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/widgets/button.dart';

final allProficiencyLevels = ['beginner', 'intermediate', 'advanced', 'expert'];

class EditSkillsScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const EditSkillsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends ConsumerState<EditSkillsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skillController = TextEditingController();
  String _selectedLevel = allProficiencyLevels[1];

  bool _isLoading = false;

  Future<void> _addSkill() async {
    final newSkill = _skillController.text.trim();
    if (newSkill.isEmpty) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    try {
      await supabase.from('user_skills').insert({
        'user_id': user?.id,
        'skill_name': newSkill,
        'proficiency_level': _selectedLevel,
      });
      _skillController.clear();
      ref.refresh(userSkillsProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSkill(String skillId) async {
    final supabase = Supabase.instance.client;
    try {
      await supabase.from('user_skills').delete().eq('id', skillId);
      ref.refresh(userSkillsProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(userSkillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Skills'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthTextField(
                    controller: _skillController,
                    label: 'Skill name',
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(labelText: 'Proficiency'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    items: allProficiencyLevels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(
                              level[0].toUpperCase() + level.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedLevel = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: "Add",
                    onPressed: _addSkill,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Your Skills:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            skillsAsync.when(
              data: (skills) => skills.isEmpty
                  ? const Text(
                      "You haven't added any skills yet.",
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map(
                            (s) => Chip(
                              label: Text(
                                '${s.skillName} (${s.proficiencyLevel})',
                              ),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () => _deleteSkill(s.id),
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
