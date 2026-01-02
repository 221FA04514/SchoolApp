import '../../models/student_dashboard_model.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  Future<StudentDashboardModel> fetchStudentDashboard() async {
    final response =
        await _api.get("/api/v1/dashboard/student");

    if (response["success"] != true) {
      throw Exception("Failed to load dashboard");
    }

    return StudentDashboardModel.fromJson(response["data"]);
  }
}
