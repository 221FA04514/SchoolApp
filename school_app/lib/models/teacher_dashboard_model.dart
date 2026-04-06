class TeacherDashboardModel {
  final String name;
  final String subject;
  final int totalStudents;
  final int pendingDoubts;
  final List todaySchedule;

  TeacherDashboardModel({
    required this.name,
    required this.subject,
    required this.totalStudents,
    required this.pendingDoubts,
    required this.todaySchedule,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      name: json["teacher"]?["name"] ?? "Anonymous",
      subject: json["teacher"]?["subject"] ?? "General",
      totalStudents: json["stats"]?["total_students"] ?? 0,
      pendingDoubts: json["stats"]?["pending_doubts"] ?? 0,
      todaySchedule: json["today_schedule"] ?? [],
    );
  }
}
