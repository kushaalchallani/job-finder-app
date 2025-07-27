import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void goToHome() {
    state = 0;
  }

  void goToFindJobs() {
    state = 1;
  }

  void goToApplications() {
    state = 2;
  }

  void goToProfile() {
    state = 3;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, int>(
  (ref) => NavigationNotifier(),
);
