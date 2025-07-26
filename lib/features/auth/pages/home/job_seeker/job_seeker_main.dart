// lib/features/auth/pages/home/job_seeker/job_seeker_main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/find_jobs.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/home_page.dart';
import 'package:job_finder_app/features/auth/pages/home/job_seeker/profile_page.dart';

class JobSeekerMainScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const JobSeekerMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobSeekerMainScreen> createState() =>
      _JobSeekerMainScreenState();
}

class _JobSeekerMainScreenState extends ConsumerState<JobSeekerMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const FindJobsScreen(),
          _buildApplicationsScreen(),
          ProfileScreen(), // Inline ProfileScreen - no external dependencies
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
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

  // Built-in Applications screen - no external dependencies
  Widget _buildApplicationsScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Applications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Coming soon!', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
