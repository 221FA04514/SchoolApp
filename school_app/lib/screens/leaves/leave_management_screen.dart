import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_service.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  late Future<List<dynamic>> _historyFuture;
  late Future<List<dynamic>> _approvalsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _historyFuture = _fetchHistory();
    _approvalsFuture = _fetchApprovals();
  }

  Future<List<dynamic>> _fetchHistory() async {
    final res = await _api.get("/api/v1/leaves/my-leaves");
    return res["data"] ?? [];
  }

  Future<List<dynamic>> _fetchApprovals() async {
    final role = Provider.of<AuthProvider>(context, listen: false).role;
    if (role == 'student') return [];
    final res = await _api.get("/api/v1/leaves");
    return res["data"] ?? [];
  }

  void _refresh() {
    setState(() {
      _historyFuture = _fetchHistory();
      _approvalsFuture = _fetchApprovals();
    });
  }

  void _approveReject(int leaveId, String status) async {
    await _api.put("/api/v1/leaves/$leaveId/status", {"status": status});
    _refresh();
  }

  void _applyLeave() {
    final reasonController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Apply for Leave",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Reason for leave",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (reasonController.text.trim().isEmpty) return;
                  await _api.post("/api/v1/leaves/apply", {
                    "reason": reasonController.text.trim(),
                    "start_date": DateTime.now().toIso8601String(),
                    "end_date": DateTime.now()
                        .add(const Duration(days: 1))
                        .toIso8601String(),
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  _refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Submit Application"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = Provider.of<AuthProvider>(context).role;
    final bool isStudent = role == 'student';

    if (isStudent) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Leaves"),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
        ),
        body: _buildLeaveList(_historyFuture, false),
        floatingActionButton: FloatingActionButton(
          onPressed: _applyLeave,
          backgroundColor: Colors.redAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Management"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Approvals"),
            Tab(text: "My Leaves"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList(_approvalsFuture, true),
          _buildLeaveList(_historyFuture, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _applyLeave,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLeaveList(Future<List<dynamic>> future, bool isApproverView) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final leaves = snapshot.data ?? [];
        if (leaves.isEmpty) {
          return const Center(child: Text("No leave records found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaves.length,
          itemBuilder: (context, index) {
            final l = leaves[index];
            final statusColor = l["status"] == 'approved'
                ? Colors.green
                : (l["status"] == 'rejected' ? Colors.red : Colors.orange);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      l["reason"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${isApproverView ? (l["student_name"] ?? 'Student') : 'Me'} • ${l["applied_at"].toString().split('T')[0]}",
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l["status"].toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  if (isApproverView && l["status"] == 'pending')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _approveReject(l["id"], "rejected"),
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                _approveReject(l["id"], "approved"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Approve"),
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
}
