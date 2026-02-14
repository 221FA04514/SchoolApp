import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/socket/socket_service.dart';
import '../../core/api/api_service.dart';

class StudentAlertsScreen extends StatefulWidget {
  const StudentAlertsScreen({super.key});

  @override
  State<StudentAlertsScreen> createState() => _StudentAlertsScreenState();
}

class _StudentAlertsScreenState extends State<StudentAlertsScreen> {
  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Initialize socket/listener
    final socketService = context.read<SocketService>();
    if (!socketService.isConnected) {
      socketService.initSocket();
    }

    // Listen for real-time updates
    socketService.notificationStream.listen((data) {
      if (mounted) {
        setState(() {
          _notifications.insert(0, {
            "title": data["title"] ?? "New Notification",
            "message": data["message"] ?? data.toString(),
            "date": "Just now",
            "type": data["type"] ?? "admin",
          });
        });
      }
    });

    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final ApiService api = ApiService();

    // Fetch Mass Notifications (Admin Alerts)
    try {
      final notifRes = await api.get("/api/v2/admin/notifications/my");
      if (mounted && notifRes["data"] != null) {
        setState(() {
          final List data = notifRes["data"];
          for (var item in data) {
            _notifications.add({
              "title": item["title"] ?? "Notification",
              "message": item["body"] ?? item["message"] ?? "",
              "date": item["created_at"]?.toString().split('T')[0] ?? "Recent",
              "type": "admin",
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching mass notifications: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load notifications: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Fetch Class Announcements
    try {
      final response = await api.get("/api/v1/announcements");
      if (mounted && response["data"] != null) {
        setState(() {
          final List data = response["data"];
          // Optional: Deduplicate if needed, assuming distinct sources
          for (var ann in data) {
            // Only add if not already present (naive check or just append)
            _notifications.add({
              "title": ann["title"] ?? "Announcement",
              "message": ann["description"] ?? ann["message"] ?? "",
              "date":
                  ann["date"] ??
                  ann["created_at"]?.toString().split('T')[0] ??
                  "Recent",
              "type":
                  ann["type"] ??
                  "teacher", // Default to teacher for class announcements
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching announcements: $e");
      // Optional: Show snackbar or silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _notifications.clear();
          await _fetchInitialData();
        },
        child: _notifications.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: const Center(child: Text("No new notifications")),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    // ... (rest of the card content)
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getColor(notif['type']!).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(notif['type']!),
                            color: _getColor(notif['type']!),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    notif['date']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notif['message']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.green;
      case 'homework':
        return Colors.indigo;
      case 'exam':
        return Colors.purple;
      case 'fees':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'admin':
        return Icons.campaign;
      case 'teacher':
        return Icons.school;
      case 'homework':
        return Icons.assignment;
      case 'exam':
        return Icons.assignment_late;
      case 'fees':
        return Icons.attach_money;
      default:
        return Icons.notifications;
    }
  }
}
