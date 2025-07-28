import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/home/job_seeker/job_details.dart';
import 'package:job_finder_app/features/home/job_seeker/job_seeker_main.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_education_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_experience_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_profile_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_skills_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/upload_resume_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications_screen.dart';

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
      path: '/applications',
      name: 'applications',
      builder: (context, state) => const ApplicationsScreen(),
    ),
  ];
}
