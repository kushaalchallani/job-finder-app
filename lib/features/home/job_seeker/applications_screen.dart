import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/application_provider.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications/application_card.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications/application_details_modal.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications/search_header.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen>
    with TickerProviderStateMixin {
  // State variables
  String? selectedStatus;
  String _searchQuery = '';
  // ignore: unused_field
  bool _isSearchExpanded = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(userApplicationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchHeader(),
            Expanded(
              child: applicationsAsync.when(
                data: (applications) => _buildApplicationsList(applications),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorState(error.toString()),
              ),
            ),
            _buildAnalyticsLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: const Text(
        'My Applications',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildSearchHeader() {
    return SearchHeader(
      searchQuery: _searchQuery,
      selectedStatus: selectedStatus,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onStatusChanged: (value) => setState(() => selectedStatus = value),
      onExpand: () => setState(() => _isSearchExpanded = true),
      onCollapse: () => setState(() => _isSearchExpanded = false),
      onClear: () => setState(() => _searchQuery = ''),
    );
  }

  Widget _buildApplicationsList(List<JobApplication> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    final filteredApplications = _filterApplications(applications);

    if (filteredApplications.isEmpty) {
      return _buildNoResultsState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          itemCount: filteredApplications.length,
          itemBuilder: (context, index) {
            final application = filteredApplications[index];
            return ApplicationCard(
              application: application,
              index: index,
              onTap: () => _showApplicationDetails(application),
            );
          },
        ),
      ),
    );
  }

  List<JobApplication> _filterApplications(List<JobApplication> applications) {
    var filtered = applications;

    if (selectedStatus != null && selectedStatus != 'All') {
      filtered = filtered.where((app) => app.status == selectedStatus).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((app) {
        return app.jobTitle.toLowerCase().contains(query) ||
            app.companyName.toLowerCase().contains(query) ||
            app.jobLocation.toLowerCase().contains(query) ||
            app.status.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void _showApplicationDetails(JobApplication application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationDetailsModal(application: application),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStateIcon(
              Icons.assignment_outlined,
              AppColors.primary.withOpacity(0.1),
              AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Applications Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start applying to jobs to see your applications here',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFindJobsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final isSearching = _searchQuery.isNotEmpty;
    final isFiltering = selectedStatus != null && selectedStatus != 'All';

    final (title, message) = _getNoResultsText(isSearching, isFiltering);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStateIcon(
            isSearching ? Icons.search_off : Icons.filter_list_off,
            AppColors.grey100,
            AppColors.grey400,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
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
          _buildStateIcon(
            Icons.error_outline,
            AppColors.error.withOpacity(0.1),
            AppColors.error,
          ),
          const SizedBox(height: 24),
          const Text(
            'Error Loading Applications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStateIcon(
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, size: 64, color: iconColor),
    );
  }

  Widget _buildAnalyticsLink() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GestureDetector(
        onTap: () => context.push('/analytics'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'View Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindJobsButton() {
    return GestureDetector(
      onTap: _showFindJobsSnackbar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Find Jobs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  (String, String) _getNoResultsText(bool isSearching, bool isFiltering) {
    if (isSearching && isFiltering) {
      return (
        'No Applications Found',
        'Try adjusting your search or filter criteria',
      );
    } else if (isSearching) {
      return (
        'No Search Results',
        'Try different keywords or check your spelling',
      );
    } else if (isFiltering) {
      return (
        'No Applications Found',
        'Try changing your filter or apply to more jobs',
      );
    } else {
      return (
        'No Applications Found',
        'Try changing your filter or apply to more jobs',
      );
    }
  }

  void _showFindJobsSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to job search'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
