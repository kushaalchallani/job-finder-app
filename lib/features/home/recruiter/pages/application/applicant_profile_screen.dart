import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/applicant-profile/applicant_profile_helpers.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/applicant-profile/applicant_profile_content.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/applicant-profile/applicant_profile_error_state.dart';

class ApplicantProfileScreen extends ConsumerStatefulWidget {
  final JobApplication application;

  const ApplicantProfileScreen({Key? key, required this.application})
    : super(key: key);

  @override
  ConsumerState<ApplicantProfileScreen> createState() =>
      _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState
    extends ConsumerState<ApplicantProfileScreen> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = loadApplicantProfile(widget.application);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            String userName = 'Loading...';
            if (snapshot.hasData && snapshot.data != null) {
              final profile = snapshot.data!['profile'] as Map<String, dynamic>;
              userName = profile['full_name'] ?? 'Unknown User';
            }
            return Text(
              '$userName\'s Profile',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            );
          },
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ApplicantProfileErrorState(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return const ApplicantProfileErrorState(
              error: 'No profile data found',
            );
          }

          final data = snapshot.data!;
          return ApplicantProfileContent(
            data: data,
            application: widget.application,
            onUpdateStatus: _updateApplicationStatus,
          );
        },
      ),
    );
  }

  void _updateApplicationStatus() {
    showUpdateApplicationStatusDialog(context, widget.application, ref);
  }
}
