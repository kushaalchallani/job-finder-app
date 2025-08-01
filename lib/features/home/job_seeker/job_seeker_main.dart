// lib/features/auth/pages/home/job_seeker/job_seeker_main_refactored.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/home/job_seeker/widgets/widgets.dart';

class JobSeekerMainScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const JobSeekerMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobSeekerMainScreen> createState() =>
      _JobSeekerMainScreenState();
}

class _JobSeekerMainScreenState extends ConsumerState<JobSeekerMainScreen> {
  @override
  void initState() {
    super.initState();
    // Reset navigation to home (index 0) when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).goToHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final navigationNotifier = ref.read(navigationProvider.notifier);

    return Scaffold(
      body: JobSeekerNavigation(currentIndex: currentIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          navigationNotifier.setIndex(index);
        },
      ),
    );
  }
}
