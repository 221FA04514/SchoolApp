class TimetableItem {
  final String day;
  final int period;
  final String subject;
  final String teacherName;
  final String startTime;
  final String endTime;
  final String className;
  final String sectionName;

  TimetableItem({
    required this.day,
    required this.period,
    required this.subject,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    this.className = '',
    this.sectionName = '',
  });

  factory TimetableItem.fromJson(Map<String, dynamic> json) {
    return TimetableItem(
      day:         json["day"]          ?? '',
      period:      json["period"]       ?? 0,
      subject:     json["subject"]      ?? '',
      teacherName: json["teacher_name"] ?? '',
      startTime:   json["start_time"]   ?? '',
      endTime:     json["end_time"]     ?? '',
      className:   json["class_name"]?.toString()   ?? '',
      sectionName: json["section_name"]?.toString() ?? '',
    );
  }

  /// e.g. "Class 9-A" or empty if not available
  String get classLabel {
    if (className.isEmpty && sectionName.isEmpty) return '';
    return 'Class $className-$sectionName';
  }
}
