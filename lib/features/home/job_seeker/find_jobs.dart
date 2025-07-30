// lib/features/auth/pages/home/job_seeker/find_jobs_refactored.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/filter_chips.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/job_list.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/search/search_states.dart';

class FindJobsScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const FindJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends ConsumerState<FindJobsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isSearchExpanded = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Expandable Search Header
            _buildExpandableSearchHeader(),

            // Job List
            Expanded(
              child: jobsAsync.when(
                data: (jobs) => JobList(
                  allJobs: jobs,
                  searchQuery: _searchQuery,
                  selectedFilter: _selectedFilter,
                  onRefresh: () => ref.refresh(jobListProvider),
                  onClearFilters: () {
                    setState(() {
                      _searchQuery = '';
                      _selectedFilter = 'All';
                    });
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => SearchStates.buildErrorState(
                  error,
                  () => ref.refresh(jobListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSearchHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // Header with Find Jobs text and Saved Jobs icon
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Find Jobs',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context.push('/saved-jobs');
                  },
                  icon: const Icon(
                    Icons.bookmark,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Expandable Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isSearchExpanded
                ? _buildExpandedSearch()
                : _buildCollapsedSearch(),
          ),

          // Filter Chips (only show when expanded)
          if (_isSearchExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: FilterChips(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _selectedFilter = filter),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSearchExpanded = true;
        });
        // Focus the search field after the layout is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isSearchExpanded) {
            _searchFocusNode.requestFocus();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.textFieldFill,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Search jobs',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintText: 'Search jobs',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.textFieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
                // Remove focus when closing
                _searchFocusNode.unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }
}
