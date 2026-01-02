import '../../models/teacher_dashboard_model.dart';
import 'api_service.dart';

class TeacherDashboardService {
  final ApiService _api = ApiService();

  Future<TeacherDashboardModel> fetchTeacherDashboard() async {
    final response = await _api.get("/api/v1/dashboard/teacher");
    return TeacherDashboardModel.fromJson(response["data"]);
  }
}
