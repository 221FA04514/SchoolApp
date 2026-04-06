class StudentPerformance {
  final int id;
  final int studentId;
  final int teacherId;
  final String performanceRating;
  final String remarks;
  final String teacherName;
  final DateTime createdAt;

  StudentPerformance({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.performanceRating,
    required this.remarks,
    required this.teacherName,
    required this.createdAt,
  });

  factory StudentPerformance.fromJson(Map<String, dynamic> json) {
    return StudentPerformance(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      teacherId: json['teacher_id'] ?? 0,
      performanceRating: json['performance_rating'] ?? '',
      remarks: json['remarks'] ?? '',
      teacherName: json['teacher_name'] ?? 'Teacher',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
