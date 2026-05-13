class Homework {
  final int id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  bool isCompleted;
  final bool needsSubmission;
  final double? marks;
  final String? feedback;
  final String? submissionStatus;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.isCompleted = false,
    this.needsSubmission = true,
    this.marks,
    this.feedback,
    this.submissionStatus,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json["id"] ?? 0,
      title: json["title"] ?? "Untitled Homework",
      description: json["description"] ?? "No description provided.",
      subject: json["subject"] ?? "General",
      dueDate: json["due_date"] != null ? DateTime.tryParse(json["due_date"].toString()) ?? DateTime.now() : DateTime.now(),
      isCompleted: (json["is_completed"] == 1 || 
                    json["is_completed"] == true || 
                    json["is_completed"].toString() == "1" || 
                    json["is_completed"].toString() == "true"),
      needsSubmission: (json["needs_submission"] == null ||
                        json["needs_submission"] == 1 || 
                        json["needs_submission"] == true || 
                        json["needs_submission"].toString() == "1" || 
                        json["needs_submission"].toString() == "true"),
      marks: json["marks"] != null ? double.tryParse(json["marks"].toString()) : null,
      feedback: json["feedback"],
      submissionStatus: json["submission_status"],
    );
  }
}
