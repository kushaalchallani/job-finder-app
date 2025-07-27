import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to fetch specific job details
final jobDetailsProvider = FutureProvider.family<JobOpening?, String>((
  ref,
  jobId,
) async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('job_openings')
        .select()
        .eq('id', jobId)
        .eq('status', 'active')
        .single();

    return JobOpening.fromJson(response);
  } catch (e) {
    return null;
  }
});
