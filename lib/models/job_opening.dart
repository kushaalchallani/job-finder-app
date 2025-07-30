class JobOpening {
  final String id;
  final String recruiterId;
  final String title;
  final String companyName;
  final String location;
  final String jobType;
  final String experienceLevel;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final String? salaryRange;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int applicationCount;
  final int viewCount;

  JobOpening({
    required this.id,
    required this.recruiterId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.jobType,
    required this.experienceLevel,
    required this.description,
    required this.requirements,
    required this.benefits,
    this.salaryRange,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.applicationCount = 0,
    this.viewCount = 0,
  });

  factory JobOpening.fromJson(Map<String, dynamic> json) {
    return JobOpening(
      id: json['id'],
      recruiterId: json['recruiter_id'],
      title: json['title'],
      companyName: json['company_name'],
      location: json['location'],
      jobType: json['job_type'],
      experienceLevel: json['experience_level'],
      description: json['description'],
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      salaryRange: json['salary_range'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      applicationCount: json['application_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recruiter_id': recruiterId,
      'title': title,
      'company_name': companyName,
      'location': location,
      'job_type': jobType,
      'experience_level': experienceLevel,
      'description': description,
      'requirements': requirements,
      'benefits': benefits,
      'salary_range': salaryRange,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'application_count': applicationCount,
      'view_count': viewCount,
    };
  }
}
