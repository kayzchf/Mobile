class CourseFeedbackModel {
  final int? id;
  final int? userId;
  final String studentName;
  final String nim;
  final String kesan;
  final String saran;
  final int ratingStars;
  final String submittedAt;

  CourseFeedbackModel({
    this.id,
    this.userId,
    required this.studentName,
    required this.nim,
    required this.kesan,
    required this.saran,
    required this.ratingStars,
    String? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'student_name': studentName,
      'nim': nim,
      'kesan': kesan,
      'saran': saran,
      'rating_stars': ratingStars,
      'submitted_at': submittedAt,
    };
  }

  factory CourseFeedbackModel.fromMap(Map<String, dynamic> map) {
    return CourseFeedbackModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      studentName: map['student_name'] as String,
      nim: map['nim'] as String,
      kesan: map['kesan'] as String,
      saran: map['saran'] as String,
      ratingStars: map['rating_stars'] as int,
      submittedAt: map['submitted_at'] as String?,
    );
  }
}

