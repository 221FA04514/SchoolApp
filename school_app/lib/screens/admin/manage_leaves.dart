import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageLeavesScreen extends StatefulWidget {
  const ManageLeavesScreen({super.key});

  @override
  State<ManageLeavesScreen> createState() => _ManageLeavesScreenState();
}

class _ManageLeavesScreenState extends State<ManageLeavesScreen> {
  final ApiService _api = ApiService();
  List leaves = [];
  bool isLoading = true;

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple

  @override
  void initState() {
    super.initState();
    _fetchLeaves();
  }

  Future<void> _fetchLeaves() async {
    try {
      final res = await _api.get("/api/v1/leaves"); // Admin endpoint
      if (mounted) {
        setState(() {
          leaves = res["data"] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      print("Error fetching leaves: $e");
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await _api.put("/api/v1/leaves/$id/status", {"status": status});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Leave $status successfully")));
        _fetchLeaves();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating status: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Leave Requests"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : leaves.isEmpty
          ? const Center(
              child: Text(
                "No pending leave requests",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final l = leaves[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: primaryColor),
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      iconColor: primaryColor,
                      collapsedIconColor: Colors.grey,
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          l["student_name"] != null
                              ? l["student_name"][0]
                              : "?",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        l["student_name"] ?? "Unknown User",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${(l["applicant_role"] ?? "").toString().toUpperCase()} • ${l["reason"] ?? "No Reason"}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                Icons.badge,
                                "Role",
                                l["applicant_role"] ?? 'N/A',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.calendar_today,
                                "Date",
                                "${l["start_date"]?.split('T')[0]} to ${l["end_date"]?.split('T')[0]}",
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.info_outline,
                                "Status",
                                l["status"],
                                isStatus: true,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                "Full Reason:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l["reason"] ?? "No reason provided",
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 20),
                              if (l["status"] == "pending")
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => _updateStatus(
                                          l["id"].toString(),
                                          "approved",
                                        ),
                                        icon: const Icon(Icons.check),
                                        label: const Text("Approve"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => _updateStatus(
                                          l["id"].toString(),
                                          "rejected",
                                        ),
                                        icon: const Icon(Icons.close),
                                        label: const Text("Reject"),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    Color? statusColor;
    if (isStatus) {
      if (value == "approved")
        statusColor = Colors.green;
      else if (value == "rejected")
        statusColor = Colors.red;
      else
        statusColor = Colors.orange;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        else
          Text(value),
      ],
    );
  }
}
