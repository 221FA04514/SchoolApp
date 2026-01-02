class StudentDashboardModel {
  final String name;
  final String className;
  final String section;
  final String roll;
  final int attendancePercentage;
  final int feesDue;
  final List announcements;

  StudentDashboardModel({
    required this.name,
    required this.className,
    required this.section,
    required this.roll,
    required this.attendancePercentage,
    required this.feesDue,
    required this.announcements,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      name: json["student"]["name"],
      className: json["student"]["class"],
      section: json["student"]["section"],
      roll: json["student"]["roll_number"],
      attendancePercentage: json["attendance"]["percentage"],
      feesDue: json["fees"]["due"],
      announcements: json["announcements"],
    );
  }
}
