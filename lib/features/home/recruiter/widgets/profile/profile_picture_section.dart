import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class ProfilePictureSection extends StatelessWidget {
  final File? profileImage;
  final String? currentProfileImageUrl;
  final bool isImageLoading;
  final VoidCallback onPickImage;

  const ProfilePictureSection({
    required this.profileImage,
    required this.currentProfileImageUrl,
    required this.isImageLoading,
    required this.onPickImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: ClipOval(
                  child: profileImage != null
                      ? Image.file(profileImage!, fit: BoxFit.cover)
                      : currentProfileImageUrl != null
                      ? Image.network(
                          currentProfileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.textSecondary,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: IconButton(
                    onPressed: isImageLoading ? null : onPickImage,
                    icon: isImageLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
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
          const SizedBox(height: 8),
          Text(
            'Tap to change photo',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
