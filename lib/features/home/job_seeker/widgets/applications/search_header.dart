import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class SearchHeader extends StatefulWidget {
  final String searchQuery;
  final String? selectedStatus;
  final Function(String) onSearchChanged;
  final Function(String?) onStatusChanged;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final VoidCallback onClear;

  const SearchHeader({
    Key? key,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onExpand,
    required this.onCollapse,
    required this.onClear,
  }) : super(key: key);

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  static const List<Map<String, dynamic>> _statusOptions = [
    {'value': 'All', 'label': 'All Applications'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'reviewed', 'label': 'Reviewed'},
    {'value': 'shortlisted', 'label': 'Shortlisted'},
    {'value': 'rejected', 'label': 'Rejected'},
    {'value': 'accepted', 'label': 'Accepted'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(SearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isSearchExpanded
                ? _buildExpandedSearch()
                : _buildCollapsedSearch(),
          ),
          if (_isSearchExpanded) ...[
            _buildFilterChips(),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return GestureDetector(
      onTap: _expandSearch,
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
            const Text(
              'Search applications',
              style: TextStyle(
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
      onChanged: widget.onSearchChanged,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        hintText: 'Search applications',
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
        suffixIcon: _buildSearchSuffixIcons(),
      ),
    );
  }

  Widget _buildSearchSuffixIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: widget.onClear,
          ),
        IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: _collapseSearch,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _statusOptions.length,
            itemBuilder: (context, index) {
              final option = _statusOptions[index];
              final isSelected = widget.selectedStatus == option['value'];

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => widget.onStatusChanged(option['value']),
                  child: _buildFilterChip(option['label'], isSelected),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      constraints: const BoxConstraints(minWidth: 80, minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.grey300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.onPrimary : AppColors.grey700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _expandSearch() {
    setState(() {
      _isSearchExpanded = true;
    });
    widget.onExpand();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isSearchExpanded) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _collapseSearch() {
    setState(() {
      _isSearchExpanded = false;
    });
    widget.onCollapse();
    _searchFocusNode.unfocus();
  }
} 