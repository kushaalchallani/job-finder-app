import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';
import 'package:job_finder_app/models/job_opening.dart';

class JobCard extends ConsumerWidget {
  final JobOpening job;

  const JobCard({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: Material(
        color: Colors.transparent,
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
                    // Company Logo
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          job.companyPictureUrl != null &&
                              job.companyPictureUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                job.companyPictureUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.business,
                                      color: AppColors.grey600,
                                    ),
                              ),
                            )
                          : Icon(Icons.business, color: AppColors.grey600),
                    ),
                    const SizedBox(width: 12),
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
                        Consumer(
                          builder: (context, ref, child) {
                            final isSavedAsync = ref.watch(
                              isJobSavedProvider(job.id),
                            );

                            return isSavedAsync.when(
                              data: (isSaved) => GestureDetector(
                                onTap: () async {
                                  final success = await ref
                                      .read(savedJobsNotifierProvider.notifier)
                                      .toggleSavedJob(job.id, ref);

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isSaved
                                              ? 'Job removed from saved'
                                              : 'Job saved!',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Icon(
                                  isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline,
                                  color: isSaved
                                      ? AppColors.primary
                                      : AppColors.grey400,
                                  size: 24,
                                ),
                              ),
                              loading: () => Icon(
                                Icons.bookmark_outline,
                                color: AppColors.grey400,
                                size: 24,
                              ),
                              error: (_, __) => Icon(
                                Icons.bookmark_outline,
                                color: AppColors.grey400,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Main content area
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              ],
            ),
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
