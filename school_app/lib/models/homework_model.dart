class Homework {
  final int id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;

  Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      id: json["id"] ?? 0,
      title: json["title"],
      description: json["description"],
      subject: json["subject"],
      dueDate: DateTime.parse(json["due_date"]),
    );
  }
}
