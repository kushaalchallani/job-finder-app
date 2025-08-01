import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';

class AnalyticsStats {
  final int totalApplications;
  final int pending;
  final int reviewed;
  final int shortlisted;
  final int accepted;
  final int rejected;
  final double successRate;
  final double avgResponseTime;
  final int monthlyApplications;

  AnalyticsStats({
    required this.totalApplications,
    required this.pending,
    required this.reviewed,
    required this.shortlisted,
    required this.accepted,
    required this.rejected,
    required this.successRate,
    required this.avgResponseTime,
    required this.monthlyApplications,
  });
}

class MainStatsCard extends StatelessWidget {
  final AnalyticsStats stats;

  const MainStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFF667EEA)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Search Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${stats.totalApplications} Applications',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMainStatItem(
                  'Success Rate',
                  '${stats.successRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMainStatItem(
                  'Avg Response',
                  '${stats.avgResponseTime.toStringAsFixed(0)} days',
                  Icons.schedule,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsStatsCalculator {
  static AnalyticsStats calculateStats(List<JobApplication> applications) {
    final total = applications.length;
    final pending = applications.where((app) => app.status == 'pending').length;
    final reviewed = applications
        .where((app) => app.status == 'reviewed')
        .length;
    final shortlisted = applications
        .where((app) => app.status == 'shortlisted')
        .length;
    final accepted = applications
        .where((app) => app.status == 'accepted')
        .length;
    final rejected = applications
        .where((app) => app.status == 'rejected')
        .length;

    final successRate = total > 0 ? (accepted / total * 100) : 0.0;
    final avgResponseTime = _calculateAvgResponseTime(applications);
    final monthlyApplications = applications
        .where(
          (app) => app.appliedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        )
        .length;

    return AnalyticsStats(
      totalApplications: total,
      pending: pending,
      reviewed: reviewed,
      shortlisted: shortlisted,
      accepted: accepted,
      rejected: rejected,
      successRate: successRate,
      avgResponseTime: avgResponseTime,
      monthlyApplications: monthlyApplications,
    );
  }

  static double _calculateAvgResponseTime(List<JobApplication> applications) {
    final applicationsWithResponse = applications
        .where((app) => app.status != 'pending' && app.reviewedAt != null)
        .toList();

    if (applicationsWithResponse.isEmpty) return 0.0;

    final totalDays = applicationsWithResponse.fold<int>(0, (sum, app) {
      final days = app.reviewedAt!.difference(app.appliedAt).inDays;
      return sum + days;
    });

    return totalDays / applicationsWithResponse.length;
  }
}
