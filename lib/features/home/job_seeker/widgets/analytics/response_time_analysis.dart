import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';

class ResponseTimeAnalysis extends StatelessWidget {
  final List<JobApplication> applications;

  const ResponseTimeAnalysis({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    final responseTimeData = _calculateResponseTimeData(applications);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Response Time Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildResponseTimeCard(
                  'Fast (< 7 days)',
                  responseTimeData.fastResponse,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResponseTimeCard(
                  'Normal (7-14 days)',
                  responseTimeData.normalResponse,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResponseTimeCard(
                  'Slow (> 14 days)',
                  responseTimeData.slowResponse,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Average response time: ${responseTimeData.averageResponseTime.toStringAsFixed(1)} days',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(color: color, size: 20, Icons.timer),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  ResponseTimeData _calculateResponseTimeData(
    List<JobApplication> applications,
  ) {
    final applicationsWithResponse = applications
        .where((app) => app.status != 'pending' && app.reviewedAt != null)
        .toList();

    int fastResponse = 0;
    int normalResponse = 0;
    int slowResponse = 0;

    for (final app in applicationsWithResponse) {
      final days = app.reviewedAt!.difference(app.appliedAt).inDays;
      if (days < 7) {
        fastResponse++;
      } else if (days <= 14) {
        normalResponse++;
      } else {
        slowResponse++;
      }
    }

    final averageResponseTime = applicationsWithResponse.isEmpty
        ? 0.0
        : applicationsWithResponse.fold<int>(0, (sum, app) {
                return sum + app.reviewedAt!.difference(app.appliedAt).inDays;
              }) /
              applicationsWithResponse.length;

    return ResponseTimeData(
      fastResponse: fastResponse,
      normalResponse: normalResponse,
      slowResponse: slowResponse,
      averageResponseTime: averageResponseTime,
    );
  }
}

class ResponseTimeData {
  final int fastResponse;
  final int normalResponse;
  final int slowResponse;
  final double averageResponseTime;

  ResponseTimeData({
    required this.fastResponse,
    required this.normalResponse,
    required this.slowResponse,
    required this.averageResponseTime,
  });
}
