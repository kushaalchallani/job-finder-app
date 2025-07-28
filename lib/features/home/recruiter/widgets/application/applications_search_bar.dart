import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class ApplicationsSearchBar extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final Function(bool)? onSearchStateChanged;

  const ApplicationsSearchBar({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    this.onSearchStateChanged,
  }) : super(key: key);

  @override
  State<ApplicationsSearchBar> createState() => _ApplicationsSearchBarState();
}

class _ApplicationsSearchBarState extends State<ApplicationsSearchBar> {
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _isSearching = widget.searchQuery.isNotEmpty;
  }

  @override
  void didUpdateWidget(ApplicationsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _searchController.text = widget.searchQuery;
      if (widget.searchQuery.isNotEmpty && !_isSearching) {
        setState(() {
          _isSearching = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _isSearching
          ? Container(
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
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearchChanged,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search applications...',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: AppColors.textFieldFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            widget.onClearSearch();
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
                            _isSearching = false;
                            _searchController.clear();
                          });
                          widget.onClearSearch();
                          widget.onSearchStateChanged?.call(false);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Row(
              children: [
                const Text(
                  'Applications',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                    widget.onSearchStateChanged?.call(true);
                  },
                ),
              ],
            ),
    );
  }
}
