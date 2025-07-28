// lib/screens/recruiter/recruiter_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_dashboard.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_applications_screen.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_jobs_screen.dart';

class RecruiterMainScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const RecruiterMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterMainScreen> createState() =>
      _RecruiterMainScreenState();
}

class _RecruiterMainScreenState extends ConsumerState<RecruiterMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const RecruiterDashboard(),
    const RecruiterJobsScreen(), // <-- Now imported from widgets/
    const RecruiterApplicationsScreen(),
    // const ProfileTab(),      // You'll create this later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: AppColors.textPrimary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.onPrimary,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.grey400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), // Changed icon
              activeIcon: Icon(Icons.work), // Changed icon
              label: 'Jobs', // Changed label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox),
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
