import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/home/recruiter/pages/application/applicant_profile_screen.dart';
import 'package:job_finder_app/features/home/recruiter/pages/application/manage_applications.dart';
import 'package:job_finder_app/features/home/recruiter/pages/jobs/create_job.dart';
import 'package:job_finder_app/features/home/recruiter/pages/jobs/edit_job.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_profile_screen.dart';
import 'package:job_finder_app/features/home/recruiter/pages/rec_settings_page.dart';
import 'package:job_finder_app/features/home/recruiter/pages/manage_account_page.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_applications_screen.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_dashboard.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_main.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/models/job_opening.dart';

class RecruiterRoutes {
  static final routes = [
    GoRoute(
      path: '/recruiter-home',
      name: 'recruiter-home',
      builder: (context, state) => const RecruiterMainScreen(),
    ),
    GoRoute(
      path: '/recruiter-applications',
      name: 'recruiter-applications',
      builder: (context, state) => const RecruiterApplicationsScreen(),
    ),
    GoRoute(
      path: '/applicant-profile',
      name: 'applicant-profile',
      builder: (context, state) {
        final application = state.extra as JobApplication;
        return ApplicantProfileScreen(application: application);
      },
    ),
    GoRoute(
      path: '/recruiter-dashboard',
      name: 'recruiter-dashboard',
      builder: (context, state) => const RecruiterDashboard(),
    ),
    GoRoute(
      path: '/create-job',
      name: 'create-job',
      builder: (context, state) => const CreateJobScreen(),
    ),
    GoRoute(
      path: '/edit-job/:jobId',
      name: 'edit-job',
      builder: (context, state) {
        final job = state.extra as JobOpening;
        return EditJobScreen(job: job);
      },
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/recruiter-profile',
      name: 'recruiter-profile',
      builder: (context, state) => const RecruiterProfileScreen(),
    ),
    GoRoute(
      path: '/manage-applications/:jobId',
      name: 'manage-applications',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;

        final job = JobOpening(
          id: jobId,
          recruiterId: '',
          title: 'Job Title',
          companyName: 'Company Name',
          location: 'Location',
          jobType: 'Full-time',
          experienceLevel: 'Mid-level',
          description: 'Job description',
          requirements: [],
          benefits: [],
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return ManageApplicationsScreen(jobId: jobId, job: job);
      },
    ),
    GoRoute(
      path: '/recruiter/manage-account',
      name: 'recruiter-manage-account',
      builder: (context, state) => const RecruiterManageAccountPage(),
    ),
  ];
}
