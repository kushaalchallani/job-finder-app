import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'widgets/profile/profile_picture_section.dart';
import 'widgets/profile/personal_info_section.dart';
import 'widgets/profile/company_info_section.dart';
import 'widgets/profile/bio_section.dart';

class RecruiterProfileScreen extends ConsumerStatefulWidget {
  const RecruiterProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterProfileScreen> createState() =>
      _RecruiterProfileScreenState();
}

class _RecruiterProfileScreenState
    extends ConsumerState<RecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  File? _profileImage;
  String? _currentProfileImageUrl;
  File? _companyProfileImage;
  String? _currentCompanyProfileImageUrl;
  bool _isLoading = false;
  bool _isImageLoading = false;
  bool _isCompanyImageLoading = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // Refresh all profile providers when the page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(userProfileProvider);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isImageLoading = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _pickCompanyImage() async {
    setState(() {
      _isCompanyImageLoading = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _companyProfileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking company image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isCompanyImageLoading = false;
      });
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _currentProfileImageUrl;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'profile-images/$fileName';

      // Upload the image
      await Supabase.instance.client.storage
          .from('profiles')
          .upload(filePath, _profileImage!);

      // Get the public URL
      final imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String?> _uploadCompanyImage() async {
    if (_companyProfileImage == null) return _currentCompanyProfileImageUrl;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final fileName =
          'company_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'company-images/$fileName';

      // Upload the image
      await Supabase.instance.client.storage
          .from('profiles')
          .upload(filePath, _companyProfileImage!);

      // Get the public URL
      final imageUrl = Supabase.instance.client.storage
          .from('profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload company image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload profile image if changed
      String? profileImageUrl = await _uploadProfileImage();
      String? companyImageUrl = await _uploadCompanyImage();

      // Update profile in database
      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': _nameController.text.trim(),
            'company': _companyNameController.text.trim(),
            'position': _positionController.text.trim(),
            'phone': _phoneController.text.trim(),
            'location': _locationController.text.trim(),
            'bio': _bioController.text.trim(),
            if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
            if (companyImageUrl != null) 'company_image_url': companyImageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      // Refresh the profile provider
      ref.invalidate(userProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Unfocus all text fields after save
        FocusScope.of(context).unfocus();
        if (context.canPop()) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
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

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile != null && !_isDataLoaded) {
          _nameController.text = userProfile.fullName ?? '';
          _companyNameController.text = userProfile.company ?? '';
          _positionController.text = userProfile.position ?? '';
          _phoneController.text = userProfile.phone ?? '';
          _locationController.text = userProfile.location ?? '';
          _bioController.text = userProfile.bio ?? '';
          _currentProfileImageUrl = userProfile.profileImageUrl;
          _currentCompanyProfileImageUrl = userProfile.companyImageUrl;
          _isDataLoaded = true;
          _profileImage =
              null; // Discard unsaved profile image changes on refresh
          _companyProfileImage =
              null; // Discard unsaved company image changes on refresh
          // Unfocus all text fields after refresh
          FocusScope.of(context).unfocus();
        }
        return WillPopScope(
          onWillPop: () async {
            FocusScope.of(context).unfocus();
            return true;
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
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
              ],
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userProfileProvider);
                  _isDataLoaded = false;
                  // Wait a moment for provider to reload
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfilePictureSection(
                          profileImage: _profileImage,
                          currentProfileImageUrl: _currentProfileImageUrl,
                          isImageLoading: _isImageLoading,
                          onPickImage: _pickImage,
                        ),
                        const SizedBox(height: 32),
                        PersonalInfoSection(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          locationController: _locationController,
                        ),
                        CompanyInfoSection(
                          companyNameController: _companyNameController,
                          positionController: _positionController,
                          companyProfileImage: _companyProfileImage,
                          currentCompanyProfileImageUrl:
                              _currentCompanyProfileImageUrl,
                          isCompanyImageLoading: _isCompanyImageLoading,
                          onPickCompanyImage: _pickCompanyImage,
                        ),
                        BioSection(bioController: _bioController),
                        const SizedBox(height: 32),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Save Changes',
                            onPressed: _saveProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
