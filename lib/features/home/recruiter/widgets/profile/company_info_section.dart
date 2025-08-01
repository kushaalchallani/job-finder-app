import 'package:flutter/material.dart';
import 'package:job_finder_app/core/widgets/text_field.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'dart:io';

class CompanyInfoSection extends StatelessWidget {
  final TextEditingController companyNameController;
  final TextEditingController positionController;
  final File? companyProfileImage;
  final String? currentCompanyProfileImageUrl;
  final bool isCompanyImageLoading;
  final VoidCallback onPickCompanyImage;

  const CompanyInfoSection({
    required this.companyNameController,
    required this.positionController,
    this.companyProfileImage,
    this.currentCompanyProfileImageUrl,
    this.isCompanyImageLoading = false,
    required this.onPickCompanyImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Company Profile Picture Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company Logo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: isCompanyImageLoading ? null : onPickCompanyImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300, width: 2),
                  ),
                  child: Stack(
                    children: [
                      if (companyProfileImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            companyProfileImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (currentCompanyProfileImageUrl != null &&
                          currentCompanyProfileImageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            currentCompanyProfileImageUrl!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          ),
                        )
                      else
                        _buildPlaceholder(),

                      // Camera icon overlay
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),

                      // Loading indicator
                      if (isCompanyImageLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to upload company logo',
                style: TextStyle(fontSize: 12, color: AppColors.grey600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        AuthTextField(controller: companyNameController, label: 'Company Name'),
        const SizedBox(height: 16),
        AuthTextField(controller: positionController, label: 'Position/Title'),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.business, size: 40, color: AppColors.grey600),
    );
  }
}
