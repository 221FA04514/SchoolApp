class Announcement {
  final int id;
  final String title;
  final String description;
  final DateTime createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
