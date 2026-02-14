import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherLeavesScreen extends StatefulWidget {
  const TeacherLeavesScreen({super.key});

  @override
  State<TeacherLeavesScreen> createState() => _TeacherLeavesScreenState();
}

class _TeacherLeavesScreenState extends State<TeacherLeavesScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _leavesFuture;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _leavesFuture = _fetchLeaves();
  }

  Future<List<dynamic>> _fetchLeaves() async {
    try {
      final res = await _api.get("/api/v1/leaves/my-leaves");
      return res["data"] ?? [];
    } catch (e) {
      debugPrint("Error fetching leaves: $e");
      return [];
    }
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    try {
      await _api.post("/api/v1/leaves/apply", {
        "reason": _reasonController.text.trim(),
        "start_date": _startDate!.toIso8601String(),
        "end_date": _endDate!.toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leave request submitted successfully")),
        );
        setState(() {
          _leavesFuture = _fetchLeaves(); // Refresh list
        });
        _reasonController.clear();
        _startDate = null;
        _endDate = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error submitting leave: $e")));
      }
    }
  }

  void _showApplyLeaveModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Apply for Leave",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reason Input
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Reason",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Reason is required" : null,
                ),
                const SizedBox(height: 15),

                // Date Selection
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        context,
                        "Start Date",
                        _startDate,
                        (date) => setModalState(() => _startDate = date),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDatePicker(
                        context,
                        "End Date",
                        _endDate,
                        (date) => setModalState(() => _endDate = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _submitLeave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(0xFF673AB7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Submit Request"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          onSelect(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? label
                  : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: TextStyle(
                color: selectedDate == null ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text("Leave Management"),
          backgroundColor: const Color(0xFF673AB7),
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "My Applications"),
              Tab(text: "Student Requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildMyLeavesList(), _buildStudentRequestsList()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showApplyLeaveModal,
          backgroundColor: const Color(0xFF673AB7),
          icon: const Icon(Icons.add),
          label: const Text("Request Leave"),
        ),
      ),
    );
  }

  Widget _buildMyLeavesList() {
    return FutureBuilder<List<dynamic>>(
      future: _leavesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final leaves = snapshot.data ?? [];
        if (leaves.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No leave history found",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final leave = leaves[index];
            final status = leave["status"] ?? "pending";

            Color statusColor;
            switch (status) {
              case "approved":
                statusColor = Colors.green;
                break;
              case "rejected":
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          leave["applied_at"] != null
                              ? "Applied: ${leave["applied_at"].toString().split('T')[0]}"
                              : "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      leave["reason"] ?? "No reason",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${leave["start_date"].toString().split('T')[0]}  ➔  ${leave["end_date"].toString().split('T')[0]}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentRequestsList() {
    return FutureBuilder<List<dynamic>>(
      future: _api.get("/api/v1/leaves").then((res) => res["data"] ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final leaves = snapshot.data ?? [];
        if (leaves.isEmpty) {
          return const Center(
            child: Text(
              "No student requests found",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          itemBuilder: (context, index) {
            final l = leaves[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
                  child: Text(
                    (l["student_name"] ?? "?")[0].toString().toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF673AB7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  l["student_name"] ?? "Unknown Student",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  l["reason"] ?? "No Reason",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Date: ${l["start_date"]?.split('T')[0]} to ${l["end_date"]?.split('T')[0]}",
                        ),
                        const SizedBox(height: 8),
                        Text("Reason: ${l["reason"] ?? 'N/A'}"),
                        const SizedBox(height: 16),
                        if (l["status"] == 'pending')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _updateStatus(
                                  l["id"].toString(),
                                  "approved",
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text("Approve"),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _updateStatus(
                                  l["id"].toString(),
                                  "rejected",
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                              ),
                            ],
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: l["status"] == 'approved'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Status: ${l["status"].toString().toUpperCase()}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: l["status"] == 'approved'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await _api.put("/api/v1/leaves/$id/status", {"status": status});
      if (mounted) {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Request $status successfully")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
