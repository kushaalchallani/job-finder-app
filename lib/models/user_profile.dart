// lib/models/user_profile.dart
class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final String? company;
  final String? phone;
  final String? bio;
  final String? location;
  final String? website;
  final String? linkedin;
  final String? github;
  final String? profileImageUrl;
  final String signUpMethod;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    this.company,
    this.phone,
    this.bio,
    this.location,
    this.website,
    this.linkedin,
    this.github,
    this.profileImageUrl,
    required this.signUpMethod,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      company: json['company'],
      phone: json['phone'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      linkedin: json['linkedin'],
      github: json['github'],
      profileImageUrl: json['profile_image_url'],
      signUpMethod: json['sign_up_method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'bio': bio,
      'location': location,
      'website': website,
      'linkedin': linkedin,
      'github': github,
      'profile_image_url': profileImageUrl,
    };
  }
}

class UserExperience {
  final String id;
  final String userId;
  final String jobTitle;
  final String companyName;
  final String? location;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final String? description;

  UserExperience({
    required this.id,
    required this.userId,
    required this.jobTitle,
    required this.companyName,
    this.location,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
  });

  factory UserExperience.fromJson(Map<String, dynamic> json) {
    return UserExperience(
      id: json['id'],
      userId: json['user_id'],
      jobTitle: json['job_title'],
      companyName: json['company_name'],
      location: json['location'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      isCurrent: json['is_current'] ?? false,
      description: json['description'],
    );
  }
}

class UserSkill {
  final String id;
  final String userId;
  final String skillName;
  final String proficiencyLevel;

  UserSkill({
    required this.id,
    required this.userId,
    required this.skillName,
    required this.proficiencyLevel,
  });

  factory UserSkill.fromJson(Map<String, dynamic> json) {
    return UserSkill(
      id: json['id'],
      userId: json['user_id'],
      skillName: json['skill_name'],
      proficiencyLevel: json['proficiency_level'],
    );
  }
}

class UserResume {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final int? fileSize;
  final bool isPrimary;
  final DateTime uploadedAt;

  UserResume({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    this.fileSize,
    required this.isPrimary,
    required this.uploadedAt,
  });

  factory UserResume.fromJson(Map<String, dynamic> json) {
    return UserResume(
      id: json['id'],
      userId: json['user_id'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileSize: json['file_size'],
      isPrimary: json['is_primary'] ?? false,
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}

class UserEducation {
  final String id;
  final String? degree, fieldOfStudy, institution, gpa, description;
  final DateTime startDate;
  final DateTime? endDate;
  // Add any other columns you wish

  UserEducation({
    required this.id,
    required this.startDate,
    this.degree,
    this.fieldOfStudy,
    this.institution,
    this.endDate,
    this.gpa,
    this.description,
  });

  factory UserEducation.fromJson(Map<String, dynamic> json) => UserEducation(
    id: json['id'] as String,
    degree: json['degree'],
    fieldOfStudy: json['field_of_study'],
    institution: json['institution'],
    gpa: json['gpa'],
    description: json['description'],
    startDate: DateTime.parse(json['start_date']),
    endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
  );
}
