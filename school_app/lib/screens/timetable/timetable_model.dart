class TimetableItem {
  final String day;
  final int period;
  final String subject;
  final String teacherName;
  final String startTime;
  final String endTime;

  TimetableItem({
    required this.day,
    required this.period,
    required this.subject,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json) {
    return TimetableItem(
      day: json["day"],
      period: json["period"],
      subject: json["subject"],
      teacherName: json["teacher_name"],
      startTime: json["start_time"],
      endTime: json["end_time"],
    );
  }
}
