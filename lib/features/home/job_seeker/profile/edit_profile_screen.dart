// ignore_for_file: unused_result, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  File? _profileImageFile;
  bool _uploadingProfileImage = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  void _loadCurrentProfile() {
    final profileAsync = ref.read(userProfileProvider);
    profileAsync.whenData((profile) {
      if (profile != null && !_isInitialized) {
        setState(() {
          _nameController.text = profile.fullName ?? '';
          _phoneController.text = profile.phone ?? '';
          _locationController.text = profile.location ?? '';
          _bioController.text = profile.bio ?? '';
          _websiteController.text = profile.website ?? '';
          _linkedinController.text = profile.linkedin ?? '';
          _githubController.text = profile.github ?? '';
          _isInitialized = true;
        });
      }
    });
  }

  Future<void> _pickAndUploadProfileImage() async {
    final picker = ImagePicker();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    setState(() {
      _uploadingProfileImage = true;
      _profileImageFile = File(picked.path);
    });

    try {
      final fileExt = path.extension(picked.path);
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';

      final bytes = await _profileImageFile!.readAsBytes();

      await Supabase.instance.client.storage
          .from('profiles')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(fileName);

      await Supabase.instance.client
          .from('profiles')
          .update({'profile_image_url': imageUrl})
          .eq('id', user.id);

      ref.refresh(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: Color(0xFF50C878),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _uploadingProfileImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    final remoteProfileImage = profileAsync.asData?.value?.profileImageUrl;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _profileImageFile != null
                            ? FileImage(_profileImageFile!)
                            : (remoteProfileImage != null
                                      ? NetworkImage(remoteProfileImage)
                                      : null)
                                  as ImageProvider<Object>?,
                        // ignore: sort_child_properties_last
                        child:
                            _profileImageFile == null &&
                                remoteProfileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Color(0xFF4A90E2),
                              )
                            : null,
                        backgroundColor: AppColors.primary.withOpacity(0.09),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _uploadingProfileImage
                              ? null
                              : _pickAndUploadProfileImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: _uploadingProfileImage
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: AppColors.onPrimary,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Profile Picture',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Form
              _buildSectionCard('Basic Information', [
                _buildInputField(
                  'Full Name',
                  _nameController,
                  'Enter your full name',
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Phone Number',
                  _phoneController,
                  'Enter your phone number',
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Location',
                  _locationController,
                  'e.g., New York, NY',
                ),
              ]),
              const SizedBox(height: 20),

              _buildSectionCard('About', [
                _buildInputField(
                  'Bio',
                  _bioController,
                  'Tell us about yourself...',
                  maxLines: 4,
                ),
              ]),
              const SizedBox(height: 20),

              _buildSectionCard('Links', [
                _buildInputField(
                  'Website',
                  _websiteController,
                  'https://yourwebsite.com',
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'LinkedIn',
                  _linkedinController,
                  'https://linkedin.com/in/yourprofile',
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'GitHub',
                  _githubController,
                  'https://github.com/yourusername',
                ),
              ]),
              const SizedBox(height: 32),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              fontWeight: FontWeight.bold,
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
        AuthTextField(controller: controller, label: hint),
      ],
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;

        if (user == null) {
          throw Exception('User not authenticated');
        }

        final profileData = {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          'location': _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          'bio': _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          'website': _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          'linkedin': _linkedinController.text.trim().isEmpty
              ? null
              : _linkedinController.text.trim(),
          'github': _githubController.text.trim().isEmpty
              ? null
              : _githubController.text.trim(),
        };

        await supabase.from('profiles').update(profileData).eq('id', user.id);

        if (mounted) {
          ref.refresh(userProfileProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Color(0xFF50C878),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: ${e.toString()}'),
              backgroundColor: AppColors.error,
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }
}
