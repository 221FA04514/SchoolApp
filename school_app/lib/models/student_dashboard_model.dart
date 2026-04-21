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
    // Robust fallbacks for attendance
    int attendance = 0;
    if (json["attendance"] != null && json["attendance"]["percentage"] != null) {
      attendance = (json["attendance"]["percentage"] as num).toInt();
    } else if (json["stats"] != null && json["stats"]["attendancePercentage"] != null) {
      attendance = (json["stats"]["attendancePercentage"] as num).toInt();
    } else if (json["attendance_percentage"] != null) {
      attendance = (json["attendance_percentage"] as num).toInt();
    }

    // Robust fallbacks for homework stats
    int pendingHw = 0;
    int completion = 0;
    if (json["stats"] != null) {
      pendingHw = (json["stats"]["pendingHomework"] ?? 0).toInt();
      completion = (json["stats"]["homeworkCompletionPercentage"] ?? 0).toInt();
    } else if (json["homework"] != null) {
      pendingHw = (json["homework"]["pending"] ?? 0).toInt();
      completion = (json["homework"]["completion_percentage"] ?? 0).toInt();
    }

    return StudentDashboardModel(
      name: json["student"]?["name"] ?? "Student",
      className: json["student"]?["class"] ?? "",
      section: json["student"]?["section"] ?? "",
      roll: json["student"]?["roll_number"] ?? "",
      attendancePercentage: attendance,
      feesDue: json["fees"]?["due"] ?? 0,
      announcements: json["announcements"] ?? [],
      pendingHomework: pendingHw,
      leavePercentage: (json["stats"]?["leavePercentage"] ?? 0).toInt(),
      homeworkCompletionPercentage: completion,
      recentLeaveStatus: json["stats"]?["recentLeaveStatus"] ?? 'None',
      recentResult: json["student"]?["recent_result"]?.toString(),
    );
  }
}
