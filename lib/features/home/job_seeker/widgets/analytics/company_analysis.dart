import 'package:flutter/material.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_application.dart';

class CompanyAnalysis extends StatelessWidget {
  final List<JobApplication> applications;

  const CompanyAnalysis({super.key, required this.applications});

  @override
  Widget build(BuildContext context) {
    final companyData = _calculateCompanyData(applications);

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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Company Analysis',
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
                child: _buildCompanyCard(
                  'Companies Applied',
                  companyData.totalCompanies.toString(),
                  Icons.business_center,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompanyCard(
                  'Top Company',
                  companyData.topCompany,
                  Icons.star,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          if (companyData.recentCompanies.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Recent Companies',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...companyData.recentCompanies
                .take(3)
                .map((company) => _buildCompanyItem(company)),
          ],
        ],
      ),
    );
  }

  Widget _buildCompanyCard(
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
            textAlign: TextAlign.center,
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

  Widget _buildCompanyItem(String company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.business,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              company,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  CompanyData _calculateCompanyData(List<JobApplication> applications) {
    final companies = <String, int>{};

    for (final app in applications) {
      companies[app.companyName] = (companies[app.companyName] ?? 0) + 1;
    }

    final sortedCompanies = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recentCompanies = applications
        .where(
          (app) => app.appliedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        )
        .map((app) => app.companyName)
        .toSet()
        .toList();

    return CompanyData(
      totalCompanies: companies.length,
      topCompany: sortedCompanies.isNotEmpty
          ? sortedCompanies.first.key
          : 'None',
      recentCompanies: recentCompanies,
    );
  }
}

class CompanyData {
  final int totalCompanies;
  final String topCompany;
  final List<String> recentCompanies;

  CompanyData({
    required this.totalCompanies,
    required this.topCompany,
    required this.recentCompanies,
  });
}
