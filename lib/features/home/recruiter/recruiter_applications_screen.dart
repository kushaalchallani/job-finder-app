import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/applications_error_state.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/recruiter_applications_helpers.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/recruiter_applications_list.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/applications_status_filter_bar.dart';
import 'package:job_finder_app/features/home/recruiter/widgets/application/applications_search_bar.dart';

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
  String _searchQuery = '';
  bool _isSearching = false;
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
    final allApplicationsAsync = ref.watch(allRecruiterApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button, Applications text and search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Only show back button when search is not expanded AND there's navigation history
                  if (!_isSearching && context.canPop())
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      onPressed: () {
                        context.pop();
                      },
                    ),
                  Expanded(
                    child: ApplicationsSearchBar(
                      searchQuery: _searchQuery,
                      onSearchChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onClearSearch: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      onSearchStateChanged: (isSearching) {
                        setState(() {
                          _isSearching = isSearching;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Status Filter Bar
            ApplicationsStatusFilterBar(
              selectedStatus: _selectedStatus,
              statusFilters: _statusFilters,
              onStatusChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),
            // Applications List
            Expanded(
              child: allApplicationsAsync.when(
                data: (applications) {
                  // Filter applications based on search query
                  var filteredApplications = applications;
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    filteredApplications = applications.where((app) {
                      return app.userFullName.toLowerCase().contains(query) ||
                          app.jobTitle.toLowerCase().contains(query) ||
                          app.companyName.toLowerCase().contains(query) ||
                          app.status.toLowerCase().contains(query);
                    }).toList();
                  }

                  return RecruiterApplicationsList(
                    applications: filteredApplications,
                    selectedStatus: _selectedStatus,
                    selectedJobId: _selectedJobId,
                    onRefresh: () async {
                      ref.invalidate(allRecruiterApplicationsProvider);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allRecruiterApplicationsProvider);
                  },
                  child: ApplicationsErrorState(error: error.toString()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
