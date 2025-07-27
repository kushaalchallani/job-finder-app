import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class NavigationConstants {
  static const List<BottomNavigationBarItem> navigationItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'Find Jobs',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assignment_outlined),
      activeIcon: Icon(Icons.assignment),
      label: 'Applications',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  static const Color selectedItemColor = AppColors.primary;
  static const Color unselectedItemColor = AppColors.textSecondary;
  static const Color backgroundColor = AppColors.surface;

  static const TextStyle selectedLabelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 12,
  );

  static const TextStyle unselectedLabelStyle = TextStyle(fontSize: 12);

  static const List<String> screenTitles = [
    'Home',
    'Find Jobs',
    'Applications',
    'Profile',
  ];
}
