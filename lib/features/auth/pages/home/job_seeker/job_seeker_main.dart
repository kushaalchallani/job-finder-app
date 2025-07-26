// lib/screens/job_seeker/job_seeker_main_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/find_jobs.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/home_page.dart';

class JobSeekerMainScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const JobSeekerMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobSeekerMainScreen> createState() =>
      _JobSeekerMainScreenState();
}

class _JobSeekerMainScreenState extends ConsumerState<JobSeekerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(), // Home tab
    const FindJobsScreen(), // Find Jobs tab
    // const ApplicationsScreen(),   // Applications tab
    // const ProfileScreen(),        // Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: _currentIndex,
          items: const [
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
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
