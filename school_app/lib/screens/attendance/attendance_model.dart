class AttendanceItem {
  final int studentId;
  final String name;
  final String rollNumber;
  String status;

  AttendanceItem({
    required this.studentId,
    required this.name,
    required this.rollNumber,
    this.status = "present",
  });

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "status": status,
    };
  }
}
