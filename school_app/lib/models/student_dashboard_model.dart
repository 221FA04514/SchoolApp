class StudentDashboardModel {
  final String name;
  final String className;
  final String section;
  final String roll;
  final int attendancePercentage;
  final int feesDue;
  final List announcements;
  final int pendingHomework;
  final int leavePercentage;
  final int homeworkCompletionPercentage;
  final String recentLeaveStatus;

  final String? recentResult;

  StudentDashboardModel({
    required this.name,
    required this.className,
    required this.section,
    required this.roll,
    required this.attendancePercentage,
    required this.feesDue,
    required this.announcements,
    this.pendingHomework = 0,
    this.leavePercentage = 0,
    this.homeworkCompletionPercentage = 0,
    this.recentLeaveStatus = 'None',
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
      pendingHomework: json["stats"]?["pendingHomework"] ?? 0,
      leavePercentage: json["stats"]?["leavePercentage"] ?? 0,
      homeworkCompletionPercentage: json["stats"]?["homeworkCompletionPercentage"] ?? 0,
      recentLeaveStatus: json["stats"]?["recentLeaveStatus"] ?? 'None',
      recentResult: json["student"]["recent_result"]?.toString(),
    );
  }
}
