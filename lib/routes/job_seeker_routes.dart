import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/analytics_page.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/job_details.dart';
import 'package:job_finder_app/features/home/job_seeker/job_seeker_main.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/settings_page.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/manage_account_page.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/profile/edit_education_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/profile/edit_experience_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/profile/edit_profile_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/profile/edit_skills_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/profile/upload_resume_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile_page.dart';
import 'package:job_finder_app/features/home/job_seeker/applications_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/find_jobs.dart';
import 'package:job_finder_app/features/home/job_seeker/pages/saved_jobs_screen.dart';

class JobSeekerRoutes {
  static final routes = [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const JobSeekerMainScreen(),
    ),
    GoRoute(
      path: '/job-details/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return JobDetailsScreen(jobId: jobId);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/upload-resume',
      builder: (context, state) => const UploadResumeScreen(),
    ),
    GoRoute(
      path: '/edit-skills',
      builder: (context, state) => const EditSkillsScreen(),
    ),
    GoRoute(
      path: '/edit-experience',
      builder: (context, state) => const EditExperienceScreen(),
    ),
    GoRoute(
      path: '/edit-education',
      builder: (context, state) => const EditEducationScreen(),
    ),
    GoRoute(
      path: '/seeker-settings',
      builder: (context, state) => const JobSeekerSettingsPage(),
    ),
    GoRoute(
      path: '/applications',
      name: 'applications',
      builder: (context, state) => const ApplicationsScreen(),
    ),
    GoRoute(
      path: '/find-jobs',
      name: 'find-jobs',
      builder: (context, state) => const FindJobsScreen(),
    ),
    GoRoute(
      path: '/saved-jobs',
      name: 'saved-jobs',
      builder: (context, state) => const SavedJobsScreen(),
    ),
    GoRoute(
      path: '/jobseeker-profile',
      name: 'jobseeker-profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/job-seeker/manage-account',
      name: 'job-seeker-manage-account',
      builder: (context, state) => const ManageAccountPage(),
    ),
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      builder: (context, state) => const AnalyticsPage(),
    ),
  ];
}
