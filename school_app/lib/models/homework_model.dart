class Homework {
  final int id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  bool isCompleted;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json["id"] ?? 0,
      title: json["title"],
      description: json["description"],
      subject: json["subject"],
      dueDate: DateTime.parse(json["due_date"]),
      isCompleted: (json["is_completed"] == 1 || json["is_completed"] == true),
    );
  }
}
