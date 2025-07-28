import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _profileDataFuture = _loadApplicantProfile();
  }

  Future<Map<String, dynamic>> _loadApplicantProfile() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch applicant profile from database
      Map<String, dynamic>? dbProfile;
      try {
        dbProfile = await supabase
            .from('profiles')
            .select()
            .eq('id', widget.application.userId)
            .maybeSingle();

        print('[DEBUG] Applicant dbProfile from Supabase: $dbProfile');
        if (dbProfile == null) {
          print(
            '[DEBUG] No profile found for user ID: ${widget.application.userId}',
          );
        }
      } catch (e) {
        print('[DEBUG] Error fetching applicant dbProfile: $e');
        dbProfile = null;
      }

      // Fetch job details from database
      Map<String, dynamic>? dbJob;
      try {
        dbJob = await supabase
            .from('job_openings')
            .select('title, company_name, location')
            .eq('id', widget.application.jobId)
            .maybeSingle();

        print('[DEBUG] Job details from Supabase: $dbJob');
        if (dbJob == null) {
          print('[DEBUG] No job found for job ID: ${widget.application.jobId}');
        }
      } catch (e) {
        print('[DEBUG] Error fetching job details: $e');
        dbJob = null;
      }

      // Prepare the profile map using the fresh data from database
      Map<String, dynamic> profileResponse = {
        'id': widget.application.userId,
        'full_name': dbProfile?['full_name'] ?? widget.application.userFullName,
        'email': dbProfile?['email'] ?? widget.application.userEmail,
        'phone': dbProfile?['phone'] ?? widget.application.userPhone,
        'location': dbProfile?['location'] ?? widget.application.userLocation,
        'website': dbProfile?['website'],
        'linkedin': dbProfile?['linkedin'],
        'github': dbProfile?['github'],
        'bio': dbProfile?['bio'],
        'profile_image_url': dbProfile?['profile_image_url'],
        // Add job details
        'job_title': dbJob?['title'] ?? widget.application.jobTitle,
        'job_company': dbJob?['company_name'] ?? widget.application.companyName,
        'job_location': dbJob?['location'] ?? widget.application.jobLocation,
      };

      print('[DEBUG] Final profileResponse used in UI: $profileResponse');
      print('[DEBUG] Using full_name: ${profileResponse['full_name']}');
      print('[DEBUG] Using email: ${profileResponse['email']}');
      print('[DEBUG] Using job_title: ${profileResponse['job_title']}');
      print('[DEBUG] Using job_company: ${profileResponse['job_company']}');
      print('[DEBUG] Using job_location: ${profileResponse['job_location']}');

      // Fetch experience
      final experience = await supabase
          .from('user_experiences')
          .select()
          .eq('user_id', widget.application.userId)
          .order('start_date', ascending: false);
      print('[DEBUG] Experience fetched: $experience');

      // Fetch education
      final education = await supabase
          .from('user_education')
          .select()
          .eq('user_id', widget.application.userId)
          .order('start_date', ascending: false);
      print('[DEBUG] Education fetched: $education');

      // Fetch skills
      final skills = await supabase
          .from('user_skills')
          .select()
          .eq('user_id', widget.application.userId)
          .order('skill_name');
      print('[DEBUG] Skills fetched: $skills');

      // Fetch resume
      final resumeList = await supabase
          .from('user_resumes')
          .select()
          .eq('user_id', widget.application.userId)
          .eq('is_primary', true)
          .limit(1);
      final resume = resumeList.isNotEmpty ? resumeList.first : null;
      print('[DEBUG] Resume fetched: $resume');

      return {
        'profile': profileResponse,
        'experience': experience,
        'education': education,
        'skills': skills,
        'resume': resume,
      };
    } catch (e, st) {
      print('[DEBUG] Exception in _loadApplicantProfile: $e');
      print(st);
      throw Exception('Failed to load applicant profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[DEBUG] ProfileScreen build called');
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
        // Removed download icon from AppBar actions
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorState('No profile data found');
          }

          final data = snapshot.data!;
          return _buildProfileContent(data);
        },
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> data) {
    final profile = data['profile'] as Map<String, dynamic>;
    final experience = data['experience'] as List;
    final education = data['education'] as List;
    final skills = data['skills'] as List;
    final resume = data['resume'] as Map<String, dynamic>?;

    print('[DEBUG] UI - Profile data: $profile');
    print('[DEBUG] UI - Full name: ${profile['full_name']}');
    print('[DEBUG] UI - Email: ${profile['email']}');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(profile),
          const SizedBox(height: 24),

          // Application Status Section
          _buildApplicationStatusSection(),
          const SizedBox(height: 24),

          // Bio Section (if available)
          if (profile['bio'] != null &&
              profile['bio'].toString().isNotEmpty &&
              profile['bio'].toString() != 'No bio available') ...[
            _buildBioSection(profile),
            const SizedBox(height: 24),
          ],

          // Contact Information
          _buildContactSection(profile),
          const SizedBox(height: 24),

          // Resume Section
          if (resume != null) ...[
            _buildResumeSection(resume),
            const SizedBox(height: 24),
          ] else ...[
            _buildNoResumeSection(),
            const SizedBox(height: 24),
          ],

          // Experience Section
          if (experience.isNotEmpty) ...[
            _buildExperienceSection(experience),
            const SizedBox(height: 24),
          ] else ...[
            _buildNoExperienceSection(),
            const SizedBox(height: 24),
          ],

          // Education Section
          if (education.isNotEmpty) ...[
            _buildEducationSection(education),
            const SizedBox(height: 24),
          ] else ...[
            _buildNoEducationSection(),
            const SizedBox(height: 24),
          ],

          // Skills Section
          if (skills.isNotEmpty) ...[
            _buildSkillsSection(skills),
            const SizedBox(height: 24),
          ] else ...[
            _buildNoSkillsSection(),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage:
                (profile['profile_image_url'] != null &&
                    (profile['profile_image_url'] as String).isNotEmpty)
                ? NetworkImage(profile['profile_image_url'])
                : null,
            child:
                (profile['profile_image_url'] == null ||
                    (profile['profile_image_url'] as String).isEmpty)
                ? Text(
                    (profile['full_name'] ?? widget.application.userFullName)
                            .isNotEmpty
                        ? (profile['full_name'] ??
                                  widget.application.userFullName)[0]
                              .toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['full_name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['job_title'] ?? 'Unknown Job',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                if (profile['location'] != null &&
                    profile['location'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile['location'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(widget.application.status),
              const Spacer(),
              Text(
                'Applied ${_formatDate(widget.application.appliedAt)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (widget.application.reviewedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reviewed ${_formatDate(widget.application.reviewedAt!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.email,
            'Email',
            profile['email'] ?? widget.application.userEmail,
          ),
          if (profile['phone'] != null)
            _buildContactItem(Icons.phone, 'Phone', profile['phone']),
          if (profile['website'] != null)
            _buildContactItem(Icons.language, 'Website', profile['website']),
          if (profile['linkedin'] != null)
            _buildContactItem(Icons.link, 'LinkedIn', profile['linkedin']),
          if (profile['github'] != null)
            _buildContactItem(Icons.code, 'GitHub', profile['github']),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeSection(Map<String, dynamic> resume) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Resume',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.download, color: AppColors.primary),
                onPressed: () async {
                  final url = resume['file_url'];
                  final fileName = resume['file_name'] ?? 'Resume.pdf';
                  if (url == null || url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No resume file URL found.'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  try {
                    // Use url_launcher to open/download the file
                    // (You must add url_launcher to your pubspec.yaml)
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading $fileName...'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      throw Exception('Could not launch URL');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to download resume: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                tooltip: 'Download Resume',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.insert_drive_file,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resume['file_name'] ?? 'Resume.pdf',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (resume['file_size'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '${(resume['file_size'] / 1024).toStringAsFixed(1)} KB',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceSection(List experience) {
    return Container(
      width: double.infinity, // <-- This makes it expand to parent width
      margin: const EdgeInsets.only(bottom: 8), // Reduced space between cards
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...experience.map((exp) => _buildExperienceItem(exp)).toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> experience) {
    final startDate = DateTime.parse(experience['start_date']);
    final endDate = experience['end_date'] != null
        ? DateTime.parse(experience['end_date'])
        : null;
    final isCurrent = experience['is_current'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  experience['job_title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            experience['company_name'],
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(startDate)} - ${isCurrent ? 'Present' : _formatDate(endDate!)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (experience['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              experience['description'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationSection(List education) {
    return Container(
      width: double.infinity, // <-- This makes it expand to parent width
      margin: const EdgeInsets.only(bottom: 8), // Reduced space between cards
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Education',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...education.map((edu) => _buildEducationItem(edu)).toList(),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    final startDate = DateTime.parse(education['start_date']);
    final endDate = education['end_date'] != null
        ? DateTime.parse(education['end_date'])
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            education['degree'] ?? 'Degree',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            education['institution'] ?? 'Institution',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(startDate)} - ${endDate != null ? _formatDate(endDate) : 'Present'}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (education['gpa'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'GPA: ${education['gpa']}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List skills) {
    return Container(
      width: double.infinity, // <-- This makes it expand to parent width
      margin: const EdgeInsets.only(bottom: 8), // Reduced space between cards
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => _buildSkillChip(skill)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(Map<String, dynamic> skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Text(
        '${skill['skill_name']} (${skill['proficiency_level']})',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _updateApplicationStatus(),
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Update Status'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        label = 'Pending';
        break;
      case 'reviewed':
        color = AppColors.info;
        label = 'Reviewed';
        break;
      case 'shortlisted':
        color = AppColors.success;
        label = 'Shortlisted';
        break;
      case 'rejected':
        color = AppColors.error;
        label = 'Rejected';
        break;
      case 'accepted':
        color = AppColors.success;
        label = 'Accepted';
        break;
      default:
        color = AppColors.grey600;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNoResumeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resume',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'No resume uploaded',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Work Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.work_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'No work experience added',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoEducationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Education',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.school_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'No education information added',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.psychology_outlined, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'No skills added',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _downloadResume() {
    // Implement resume download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume download started...'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _updateApplicationStatus() {
    final statusController = TextEditingController(
      text: widget.application.status,
    );
    final notesController = TextEditingController(
      text: widget.application.recruiterNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status - ${widget.application.userFullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: widget.application.status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'reviewed', child: Text('Reviewed')),
                DropdownMenuItem(
                  value: 'shortlisted',
                  child: Text('Shortlisted'),
                ),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
              ],
              onChanged: (value) {
                if (value != null) {
                  statusController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Add any notes about this application...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Here you would call the service to update the application status
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Application status updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(Map<String, dynamic> profile) {
    return Container(
      width: double.infinity, // <-- This makes it expand to parent width
      margin: const EdgeInsets.only(bottom: 8), // Reduced space between cards
      padding: const EdgeInsets.all(16), // Padding inside the card
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile['bio'] ?? 'No bio available',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }
}
