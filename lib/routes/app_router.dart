import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/features/auth/pages/auth/forgot_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/recruiter_sign_up_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/reset_password_page.dart';
import 'package:job_finder_app/features/auth/pages/auth/sign_up_page.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_education_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_experience_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_profile_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/job_details.dart';
import 'package:job_finder_app/features/home/job_seeker/job_seeker_main.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/edit_skills_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/profile/upload_resume_screen.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/applications_screen.dart';
import 'package:job_finder_app/features/home/recruiter/manage_applications.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_applications_screen.dart';
import 'package:job_finder_app/features/home/recruiter/applicant_profile_screen.dart';
import 'package:job_finder_app/features/home/recruiter/create_job.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/models/job_application.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_main.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/pages/splash_page.dart';
import '../features/auth/pages/auth/login_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(
          key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          errorMessage: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const JobSeekerMainScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/recruiter-signup',
        name: 'recruiter-signup',
        builder: (context, state) => const RecruiterSignUpPage(),
      ),
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
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final location = state.matchedLocation;

      final publicRoutes = [
        '/login',
        '/signup',
        '/forgot-password',
        '/reset-password',
      ];

      if (!isLoggedIn) {
        return publicRoutes.contains(location) ? null : '/login';
      }

      final role = session.user.userMetadata?['role'] as String?;
      final isRecruiter = role == 'recruiter';

      if (location == '/home' && isRecruiter) return '/recruiter-home';
      if (location == '/recruiter-home' && !isRecruiter) return '/home';

      if (publicRoutes.contains(location)) {
        // prevent logged-in users from visiting login/signup again
        return isRecruiter ? '/recruiter-home' : '/home';
      }

      return null;
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) => AppRouter.router);
