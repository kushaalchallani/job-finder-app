class JobApplication {
  final String id;
  final String jobId;
  final String userId;
  final String
  status; // 'pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? recruiterNotes;
  final String? coverLetter;
  final String? resumeUrl;
  final String? resumeFileName;

  // Job details (for easy access)
  final String jobTitle;
  final String companyName;
  final String jobLocation;

  // User details (for recruiter view)
  final String userFullName;
  final String userEmail;
  final String? userPhone;
  final String? userLocation;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.status,
    required this.appliedAt,
    this.reviewedAt,
    this.recruiterNotes,
    this.coverLetter,
    this.resumeUrl,
    this.resumeFileName,
    required this.jobTitle,
    required this.companyName,
    required this.jobLocation,
    required this.userFullName,
    required this.userEmail,
    this.userPhone,
    this.userLocation,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'],
      jobId: json['job_id'],
      userId: json['user_id'],
      status: json['status'],
      appliedAt: DateTime.parse(json['applied_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      recruiterNotes: json['recruiter_notes'],
      coverLetter: json['cover_letter'],
      resumeUrl: json['resume_url'],
      resumeFileName: json['resume_file_name'],
      jobTitle:
          json['job_openings']?['title'] ?? json['job_title'] ?? 'Unknown Job',
      companyName:
          json['job_openings']?['company_name'] ??
          json['company_name'] ??
          'Unknown Company',
      jobLocation:
          json['job_openings']?['location'] ??
          json['job_location'] ??
          'Unknown Location',
      userFullName:
          json['profiles']?['full_name'] ??
          json['user_full_name'] ??
          'Unknown User',
      userEmail: json['profiles']?['email'] ?? json['user_email'] ?? 'No email',
      userPhone: json['profiles']?['phone'] ?? json['user_phone'],
      userLocation: json['profiles']?['location'] ?? json['user_location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'user_id': userId,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'recruiter_notes': recruiterNotes,
      'cover_letter': coverLetter,
      'resume_url': resumeUrl,
      'resume_file_name': resumeFileName,
      'job_title': jobTitle,
      'company_name': companyName,
      'job_location': jobLocation,
      'user_full_name': userFullName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'user_location': userLocation,
    };
  }

  JobApplication copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
    String? recruiterNotes,
    String? coverLetter,
    String? resumeUrl,
    String? resumeFileName,
    String? jobTitle,
    String? companyName,
    String? jobLocation,
    String? userFullName,
    String? userEmail,
    String? userPhone,
    String? userLocation,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      recruiterNotes: recruiterNotes ?? this.recruiterNotes,
      coverLetter: coverLetter ?? this.coverLetter,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      jobLocation: jobLocation ?? this.jobLocation,
      userFullName: userFullName ?? this.userFullName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userLocation: userLocation ?? this.userLocation,
    );
  }
}
