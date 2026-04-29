class TeacherDashboardModel {
  final String name;
  final String subject;
  final String phone;
  final String email;
  final int totalStudents;
  final int pendingDoubts;
  final List todaySchedule;

  TeacherDashboardModel({
    required this.name,
    required this.subject,
    required this.phone,
    required this.email,
    required this.totalStudents,
    required this.pendingDoubts,
    required this.todaySchedule,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      name:          json["teacher"]?["name"]    ?? "Unknown",
      subject:       json["teacher"]?["subject"] ?? "General",
      phone:         json["teacher"]?["phone"]   ?? "",
      email:         json["teacher"]?["email"]   ?? "",
      totalStudents: json["stats"]?["total_students"] ?? 0,
      pendingDoubts: json["stats"]?["pending_doubts"] ?? 0,
      todaySchedule: json["today_schedule"] ?? [],
    );
  }
}

