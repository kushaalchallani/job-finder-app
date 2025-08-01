import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final String userName;

  // ignore: use_super_parameters
  const HomeHeader({
    Key? key,
    this.userName = 'John Doe', // You can make this dynamic later
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()},',
              style: TextStyle(fontSize: 16, color: AppColors.grey600),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        // Removed notification button
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
