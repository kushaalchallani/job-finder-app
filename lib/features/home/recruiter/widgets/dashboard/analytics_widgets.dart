// ignore_for_file: deprecated_member_use, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/core/providers/recruiter_analytics_provider.dart';
import 'dart:async';
import 'package:job_finder_app/core/theme/app_theme.dart';

class AnalyticsOverview extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const AnalyticsOverview({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsOverview> createState() => _AnalyticsOverviewState();
}

class _AnalyticsOverviewState extends ConsumerState<AnalyticsOverview> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      ref.invalidate(recruiterAnalyticsProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(recruiterAnalyticsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Icon(Icons.sync, size: 16, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  'Auto-refresh 30s',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.invalidate(recruiterAnalyticsProvider);
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.primary),
                  tooltip: 'Refresh Analytics',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        analyticsAsync.when(
          data: (analytics) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Jobs',
                      '${analytics.totalJobs}',
                      Icons.work,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Total Applications',
                      '${analytics.totalApplications}',
                      Icons.people,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Views',
                      '${analytics.totalViews}',
                      Icons.visibility,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Avg. Time to Fill',
                      '${analytics.averageTimeToFill.toStringAsFixed(1)} days',
                      Icons.schedule,
                      AppColors.brandPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Conversion Rate Card
              _buildConversionRateCard(analytics.conversionRates),
              const SizedBox(height: 24),

              // Application Status Chart
              _buildApplicationStatusChart(analytics.applicationStatusCounts),
              const SizedBox(height: 24),

              // Weekly Trends Chart
              _buildWeeklyTrendsChart(analytics.weeklyTrends),
              const SizedBox(height: 24),

              // Top Performing Jobs
              _buildTopPerformingJobs(analytics.topPerformingJobs),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.onPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Error loading analytics: ${error.toString()}'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRateCard(Map<String, double> conversionRates) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversion Rates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildConversionRateItem(
                  'Overall',
                  conversionRates['overall'] ?? 0,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildConversionRateItem(
                  'This Month',
                  conversionRates['this_month'] ?? 0,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildConversionRateItem(
                  'Last Month',
                  conversionRates['last_month'] ?? 0,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversionRateItem(String label, double rate, Color color) {
    return Column(
      children: [
        Text(
          '${rate.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
      ],
    );
  }

  Widget _buildApplicationStatusChart(Map<String, int> statusCounts) {
    final total = statusCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No applications yet')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...statusCounts.entries.map((entry) {
            final percentage = (entry.value / total) * 100;
            return _buildStatusBar(entry.key, entry.value, percentage);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String status, int count, double percentage) {
    final color = _getStatusColor(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatStatus(status),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 14, color: AppColors.grey600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.grey200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'reviewed':
        return AppColors.info;
      case 'shortlisted':
        return AppColors.brandPurple;
      case 'rejected':
        return AppColors.error;
      case 'accepted':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.substring(0, 1).toUpperCase() +
        status.substring(1).toLowerCase();
  }

  Widget _buildWeeklyTrendsChart(List<ApplicationTrend> trends) {
    if (trends.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No trend data available')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Application Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: trends.map((trend) {
                final maxApplications = trends
                    .map((t) => t.applications)
                    .reduce((a, b) => a > b ? a : b);
                final height = maxApplications > 0
                    ? (trend.applications / maxApplications)
                    : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${trend.applications}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 20,
                      height: 120 * height,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      trend.week,
                      style: TextStyle(fontSize: 10, color: AppColors.grey600),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingJobs(List<JobPerformance> topJobs) {
    if (topJobs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No job performance data available')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...topJobs.map((job) => _buildJobPerformanceItem(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildJobPerformanceItem(JobPerformance job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.jobTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPerformanceMetric('Applications', '${job.applications}'),
              const SizedBox(width: 16),
              _buildPerformanceMetric('Views', '${job.views}'),
              const SizedBox(width: 16),
              _buildPerformanceMetric(
                'Conversion',
                '${job.conversionRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: job.status == 'active'
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: job.status == 'active'
                    ? AppColors.success
                    : AppColors.grey,
              ),
            ),
            child: Text(
              job.status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: job.status == 'active'
                    ? AppColors.success
                    : AppColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600)),
      ],
    );
  }
}
