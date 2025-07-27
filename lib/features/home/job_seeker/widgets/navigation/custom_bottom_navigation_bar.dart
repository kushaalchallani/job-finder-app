import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/navigation/navigation_constants.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NavigationConstants.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: NavigationConstants.backgroundColor,
        selectedItemColor: NavigationConstants.selectedItemColor,
        unselectedItemColor: NavigationConstants.unselectedItemColor,
        selectedLabelStyle: NavigationConstants.selectedLabelStyle,
        unselectedLabelStyle: NavigationConstants.unselectedLabelStyle,
        currentIndex: currentIndex,
        items: NavigationConstants.navigationItems,
        onTap: onTap,
      ),
    );
  }
}
