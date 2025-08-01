import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_finder_app/core/providers/job_provider.dart';

// Provider to fetch specific job details
final jobDetailsProvider = FutureProvider.family<JobOpening?, String>((
  ref,
  jobId,
) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('job_openings')
        .select('''
          *,
          profiles!job_openings_recruiter_id_fkey(company_image_url)
        ''')
        .eq('id', jobId)
        .eq('status', 'active')
        .single();

    // Extract company image URL
    final recruiterProfile = response['profiles'] as Map<String, dynamic>?;
    final companyPictureUrl = recruiterProfile?['company_image_url'];

    final jobWithPicture = {
      ...response,
      'company_picture_url': companyPictureUrl,
    };

    final job = JobOpening.fromJson(jobWithPicture);

    // Track the job view automatically when job is fetched
    trackJobView(jobId);

    return job;
  } catch (e) {
    return null;
  }
});
