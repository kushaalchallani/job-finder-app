import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';

class JobCard extends StatelessWidget {
  final JobOpening job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/job-details/${job.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.companyName,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job.jobType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.bookmark_outline, color: AppColors.grey400),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    job.location,
                    style: TextStyle(color: AppColors.grey600),
                  ),
                  if (job.salaryRange != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.salaryRange!,
                      style: TextStyle(color: AppColors.grey600),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              Text(
                job.description.length > 120
                    ? '${job.description.substring(0, 120)}...'
                    : job.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey700,
                  height: 1.4,
                ),
              ),

              if (job.requirements.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: job.requirements
                      .take(3)
                      .map(
                        (req) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            req,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grey700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 8),
              Text(
                'Posted ${_getTimeAgo(job.createdAt)}',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
  }
}
