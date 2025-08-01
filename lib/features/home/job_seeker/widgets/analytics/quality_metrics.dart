import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';

class QualityMetrics extends StatelessWidget {
  final List<JobApplication> applications;

  const QualityMetrics({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    final qualityData = _calculateQualityMetrics(applications);

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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assessment,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Application Quality',
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
                child: _buildQualityCard(
                  'Success Rate',
                  '${qualityData.successRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQualityCard(
                  'Interview Rate',
                  '${qualityData.interviewRate.toStringAsFixed(1)}%',
                  Icons.people,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQualityCard(
                  'Rejection Rate',
                  '${qualityData.rejectionRate.toStringAsFixed(1)}%',
                  Icons.cancel,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
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

  QualityMetricsData _calculateQualityMetrics(
    List<JobApplication> applications,
  ) {
    if (applications.isEmpty) {
      return QualityMetricsData(
        successRate: 0.0,
        interviewRate: 0.0,
        rejectionRate: 0.0,
        insight: 'Start applying to jobs to see quality metrics',
      );
    }

    final total = applications.length;
    final accepted = applications
        .where((app) => app.status == 'accepted')
        .length;
    final shortlisted = applications
        .where((app) => app.status == 'shortlisted')
        .length;
    final rejected = applications
        .where((app) => app.status == 'rejected')
        .length;

    final successRate = (accepted / total) * 100;
    final interviewRate = ((accepted + shortlisted) / total) * 100;
    final rejectionRate = (rejected / total) * 100;

    String insight;
    if (successRate > 20) {
      insight =
          'Excellent success rate! Your applications are highly effective.';
    } else if (successRate > 10) {
      insight = 'Good progress! Consider improving your resume and targeting.';
    } else {
      insight = 'Focus on improving application quality and company research.';
    }

    return QualityMetricsData(
      successRate: successRate,
      interviewRate: interviewRate,
      rejectionRate: rejectionRate,
      insight: insight,
    );
  }
}

class QualityMetricsData {
  final double successRate;
  final double interviewRate;
  final double rejectionRate;
  final String insight;

  QualityMetricsData({
    required this.successRate,
    required this.interviewRate,
    required this.rejectionRate,
    required this.insight,
  });
}
