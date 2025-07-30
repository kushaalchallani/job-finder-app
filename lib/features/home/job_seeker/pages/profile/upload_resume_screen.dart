// lib/screens/job_seeker/upload_resume_screen.dart
// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/profile_provider.dart';
import 'package:job_finder_app/core/widgets/button.dart';

class UploadResumeScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const UploadResumeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends ConsumerState<UploadResumeScreen> {
  File? _selectedFile;
  String? _fileName;
  int? _fileSize;
  bool _isUploading = false;
  bool _isPrimary = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Upload Resume',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Selection Section
            _buildFileSelectionCard(),
            const SizedBox(height: 20),

            // Primary Resume Toggle
            if (_selectedFile != null) ...[
              _buildPrimaryToggleCard(),
              const SizedBox(height: 20),
            ],

            // Upload Instructions
            _buildInstructionsCard(),
            const SizedBox(height: 32),

            // Upload Button
            if (_selectedFile != null)
              PrimaryButton(
                text: 'Upload Resume',
                onPressed: _uploadResume,
                isLoading: _isUploading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectionCard() {
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
        border: _selectedFile != null
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          if (_selectedFile == null) ...[
            // File picker UI
            Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Resume File',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a PDF or DOC file from your device',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(text: 'Browse Files', onPressed: _pickFile),
          ] else ...[
            // Selected file display
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName ?? 'Unknown file',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(_fileSize ?? 0),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'File selected successfully',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryToggleCard() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set as Primary Resume',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'This resume will be used by default when applying for jobs',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value;
              });
            },
            activeColor: const Color(0xFF4A90E2),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Upload Guidelines',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideline('• Accepted formats: PDF, DOC, DOCX'),
          _buildGuideline('• Maximum file size: 10 MB'),
          _buildGuideline('• Use a professional, well-formatted resume'),
          _buildGuideline('• Include relevant experience and skills'),
          _buildGuideline('• Ensure contact information is up to date'),
        ],
      ),
    );
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.blue[800]),
      ),
    );
  }

  IconData _getFileIcon() {
    if (_fileName == null) return Icons.description;

    final extension = path.extension(_fileName!).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      default:
        return Icons.description;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;
        final fileSize = result.files.first.size;

        // Check file size (max 10 MB)
        if (fileSize > 10 * 1024 * 1024) {
          _showError('File size must be less than 10 MB');
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = fileName;
          _fileSize = fileSize;
        });
      }
    } catch (e) {
      _showError('Error selecting file: ${e.toString()}');
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileSize = null;
      _isPrimary = false;
    });
  }

  void _uploadResume() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(_fileName!);
      final uniqueFileName = '${user.id}/${timestamp}_${_fileName!}';

      // Upload file to Supabase Storage
      final uploadResponse = await supabase.storage
          .from('resumes')
          .upload(uniqueFileName, _selectedFile!);

      // Get public URL
      final fileUrl = supabase.storage
          .from('resumes')
          .getPublicUrl(uniqueFileName);

      // If this is set as primary, unset other primary resumes
      if (_isPrimary) {
        await supabase
            .from('user_resumes')
            .update({'is_primary': false})
            .eq('user_id', user.id);
      }

      // Save resume info to database
      await supabase.from('user_resumes').insert({
        'user_id': user.id,
        'file_name': _fileName,
        'file_url': fileUrl,
        'file_size': _fileSize,
        'is_primary': _isPrimary,
      });

      if (mounted) {
        // Refresh the resumes provider
        // ignore: unused_result
        ref.refresh(userResumesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume uploaded successfully!'),
            backgroundColor: Color(0xFF50C878),
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.pop();
      }
    } catch (e) {
      _showError('Error uploading resume: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
