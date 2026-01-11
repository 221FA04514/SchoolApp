import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManagePeriodSettingsScreen extends StatefulWidget {
  const ManagePeriodSettingsScreen({super.key});

  @override
  State<ManagePeriodSettingsScreen> createState() =>
      _ManagePeriodSettingsScreenState();
}

class _ManagePeriodSettingsScreenState
    extends State<ManagePeriodSettingsScreen> {
  final ApiService _api = ApiService();
  List settings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      final res = await _api.get("/api/v1/admin/period-settings");
      setState(() {
        settings = res["data"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAddEditSettingDialog([Map? setting]) {
    final periodController = TextEditingController(
      text: setting != null ? setting["period_number"].toString() : "",
    );
    final startController = TextEditingController(
      text: setting != null ? setting["start_time"] : "",
    );
    final endController = TextEditingController(
      text: setting != null ? setting["end_time"] : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          setting == null ? "Add Period Timing" : "Edit Period Timing",
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: periodController,
              decoration: const InputDecoration(
                labelText: "Period Number (e.g. 1)",
              ),
              keyboardType: TextInputType.number,
              enabled: setting == null,
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: "Start Time (HH:mm)",
              ),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(labelText: "End Time (HH:mm)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _api.post("/api/v1/admin/period-settings", {
                  "period_number": int.parse(periodController.text),
                  "start_time": startController.text,
                  "end_time": endController.text,
                });
                if (mounted) Navigator.pop(context);
                fetchSettings();
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Time Management")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: settings.length,
              itemBuilder: (context, index) {
                final s = settings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(s["period_number"].toString()),
                    ),
                    title: Text("${s["start_time"]} - ${s["end_time"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditSettingDialog(s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await _api.delete(
                                "/api/v1/admin/period-settings/${s["id"]}",
                              );
                              fetchSettings();
                            } catch (e) {
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditSettingDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
