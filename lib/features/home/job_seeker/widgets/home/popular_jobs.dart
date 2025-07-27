import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/core/theme/app_theme.dart';
import 'package:job_finder_app/models/job_opening.dart';

class PopularJobs extends StatelessWidget {
  final List<JobOpening> jobs;
  final VoidCallback? onViewAll;

  const PopularJobs({Key? key, required this.jobs, this.onViewAll})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Most Popular Jobs 🔥',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: onViewAll, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),

        if (jobs.isEmpty)
          _buildNoJobsState()
        else
          // ignore: unnecessary_to_list_in_spreads
          ...jobs.take(4).map((job) => _buildJobCard(job)).toList(),
      ],
    );
  }

  Widget _buildNoJobsState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.work_off_outlined, color: AppColors.grey400, size: 48),
            const SizedBox(height: 8),
            const Text('No popular jobs available right now'),
            const SizedBox(height: 4),
            Text(
              'Check back later for new opportunities!',
              style: TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(JobOpening job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Builder(
        builder: (context) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/job-details/${job.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            job.jobType.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.bookmark_outline,
                          color: AppColors.grey400,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location,
                      style: TextStyle(color: AppColors.grey600, fontSize: 12),
                    ),
                    if (job.salaryRange != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.attach_money,
                        size: 14,
                        color: AppColors.grey600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.salaryRange!,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),

                if (job.requirements.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: job.requirements
                        .take(2)
                        .map(
                          (req) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              req,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PopularJobsLoading extends StatelessWidget {
  const PopularJobsLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Most Popular Jobs 🔥',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: null, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        _buildJobCardLoading(),
        _buildJobCardLoading(),
      ],
    );
  }

  Widget _buildJobCardLoading() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularJobsError extends StatelessWidget {
  final Object error;

  const PopularJobsError({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Popular Jobs 🔥',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppColors.grey400, size: 48),
                const SizedBox(height: 8),
                const Text('Failed to load popular jobs'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Refresh is handled by the parent RefreshIndicator
                  },
                  child: const Text('Pull down to refresh'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
