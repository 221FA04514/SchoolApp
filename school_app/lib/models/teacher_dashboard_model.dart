class TeacherDashboardModel {
  final String name;
  final String subject;
  final int totalStudents;
  final int pendingDoubts;

  TeacherDashboardModel({
    required this.name,
    required this.subject,
    required this.totalStudents,
    required this.pendingDoubts,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      name: json["teacher"]["name"],
      subject: json["teacher"]["subject"],
      totalStudents: json["stats"]["total_students"],
      pendingDoubts: json["stats"]["pending_doubts"],
    );
  }
}
