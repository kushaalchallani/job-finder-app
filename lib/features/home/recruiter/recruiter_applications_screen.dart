import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/recruiter_jobs_provider.dart';
import 'package:job_finder_app/core/providers/application_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/recruiter/applicant_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecruiterApplicationsScreen extends ConsumerStatefulWidget {
  const RecruiterApplicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterApplicationsScreen> createState() =>
      _RecruiterApplicationsScreenState();
}

class _RecruiterApplicationsScreenState
    extends ConsumerState<RecruiterApplicationsScreen> {
  String _selectedStatus = 'All';
  String? _selectedJobId;
  final List<String> _statusFilters = [
    'All',
    'pending',
    'reviewed',
    'shortlisted',
    'rejected',
    'accepted',
  ];

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(recruiterJobsProvider);
    final allApplicationsAsync = ref.watch(_allRecruiterApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Applications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),

          // Applications List
          Expanded(
            child: allApplicationsAsync.when(
              data: (applications) => _buildApplicationsList(applications),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', _selectedStatus == 'All'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', _selectedStatus == 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Reviewed', _selectedStatus == 'reviewed'),
            const SizedBox(width: 8),
            _buildFilterChip('Shortlisted', _selectedStatus == 'shortlisted'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', _selectedStatus == 'rejected'),
            const SizedBox(width: 8),
            _buildFilterChip('Accepted', _selectedStatus == 'accepted'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? label : 'All';
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildApplicationsList(List<JobApplication> applications) {
    // Apply filters
    var filteredApplications = applications;

    if (_selectedStatus != 'All') {
      filteredApplications = applications
          .where((app) => app.status == _selectedStatus)
          .toList();
    }

    if (_selectedJobId != null) {
      filteredApplications = filteredApplications
          .where((app) => app.jobId == _selectedJobId)
          .toList();
    }

    if (filteredApplications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredApplications.length,
      itemBuilder: (context, index) {
        final application = filteredApplications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(JobApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header with applicant info and status
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  application.userFullName.isNotEmpty
                      ? application.userFullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.userFullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      application.jobTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(application.status),
            ],
          ),

          const SizedBox(height: 12),

          // Job and company info
          Row(
            children: [
              const Icon(
                Icons.business,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                application.companyName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Applied ${_formatDate(application.appliedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Contact info
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  application.userEmail,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          if (application.userPhone != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  application.userPhone!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewApplicantProfile(application),
                  icon: const Icon(Icons.person, size: 16),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateApplicationStatus(application),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          const Text(
            'No Applications Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Applications will appear here once candidates apply to your jobs',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
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
            'Error Loading Applications',
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Applications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by Job:'),
            const SizedBox(height: 8),
            // Add job filter dropdown here
            const Text('Filter by Status:'),
            const SizedBox(height: 8),
            // Add status filter dropdown here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _viewApplicantProfile(JobApplication application) {
    context.push('/applicant-profile', extra: application);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _updateApplicationStatus(JobApplication application) {
    final statusController = TextEditingController(text: application.status);
    final notesController = TextEditingController(
      text: application.recruiterNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status - ${application.userFullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: application.status,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Provider to get all applications for recruiter's jobs
final _allRecruiterApplicationsProvider = FutureProvider<List<JobApplication>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');

  try {
    // First get all jobs by this recruiter
    final jobs = await Supabase.instance.client
        .from('job_openings')
        .select('id')
        .eq('recruiter_id', user.id);

    if (jobs.isEmpty) return [];

    // Get all applications for these jobs
    final jobIds = jobs.map((job) => job['id']).toList();

    final applications = await Supabase.instance.client
        .from('job_applications')
        .select()
        .inFilter('job_id', jobIds)
        .order('applied_at', ascending: false);

    return applications.map((app) => JobApplication.fromJson(app)).toList();
  } catch (e) {
    throw Exception('Failed to fetch applications: $e');
  }
});
