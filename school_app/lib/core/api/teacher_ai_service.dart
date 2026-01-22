import 'api_service.dart';

class TeacherAiService {
  final ApiService _api = ApiService();

  Future<String> refineAnnouncement(String draft) async {
    final response = await _api.post("/api/v1/ai/teacher/announcement-fix", {
      "draft": draft,
    });
    return response["data"]["refined"] ?? "";
  }

  Future<List<Map<String, dynamic>>> generateHomework({
    required String subject,
    required String topic,
    required String difficulty,
    int count = 5,
  }) async {
    final response = await _api.post("/api/v1/ai/teacher/homework-gen", {
      "subject": subject,
      "topic": topic,
      "difficulty": difficulty,
      "count": count,
    });

    final List<dynamic> questions = response["data"]["questions"] ?? [];
    return List<Map<String, dynamic>>.from(questions);
  }

  Future<String> getStudentInsights(String studentId) async {
    final response = await _api.get("/api/v1/ai/teacher/insights/$studentId");
    return response["data"]["insights"] ?? "";
  }

  Future<List<Map<String, dynamic>>> getInsightDetails(String type) async {
    final response = await _api.get(
      "/api/v1/ai/teacher/insights-detail?type=$type",
    );
    final List<dynamic> list =
        response["data"]["students"] ?? response["data"]["pending"] ?? [];
    return List<Map<String, dynamic>>.from(list);
  }
}
