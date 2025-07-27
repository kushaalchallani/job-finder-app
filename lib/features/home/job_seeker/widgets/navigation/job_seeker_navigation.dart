import 'package:flutter/material.dart';
import 'package:job_finder_app/features/home/job_seeker/find_jobs.dart';
import 'package:job_finder_app/features/home/job_seeker/home_page.dart';
import 'package:job_finder_app/features/home/job_seeker/profile_page.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications_screen.dart';

class JobSeekerNavigation extends StatelessWidget {
  final int currentIndex;

  const JobSeekerNavigation({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentIndex,
      children: const [
        HomeScreen(),
        FindJobsScreen(),
        ApplicationsScreen(),
        ProfileScreen(),
      ],
    );
  }
}
