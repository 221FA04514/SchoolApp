class StudentDashboardModel {
  final String name;
  final String className;
  final String section;
  final String roll;
  final int attendancePercentage;
  final int feesDue;
  final List announcements;

  final String? recentResult;

  StudentDashboardModel({
    required this.name,
    required this.className,
    required this.section,
    required this.roll,
    required this.attendancePercentage,
    required this.feesDue,
    required this.announcements,
    this.recentResult,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      name: json["student"]["name"] ?? "Student",
      className: json["student"]["class"] ?? "",
      section: json["student"]["section"] ?? "",
      roll: json["student"]["roll_number"] ?? "",
      attendancePercentage: json["attendance"]["percentage"] ?? 0,
      feesDue: json["fees"]["due"] ?? 0,
      announcements: json["announcements"] ?? [],
      recentResult: json["student"]["recent_result"]?.toString(),
    );
  }
}
