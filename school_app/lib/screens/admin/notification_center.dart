import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final ApiService _api = ApiService();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  List<Map<String, dynamic>> targets = [];
  List sections = [];
  bool isAiLoading = false;
  DateTime? expiryDate;
  List sharedNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _fetchHistory();
  }

  Future<void> _fetchSections() async {
    try {
      final res = await _api.get("/api/v1/sections");
      if (mounted) setState(() => sections = res["data"] ?? []);
    } catch (e) {}
  }

  void _addTarget(String type, dynamic id, String label) {
    if (targets.any((t) => t["type"] == type && t["id"] == id)) return;
    setState(() {
      targets.add({"type": type, "id": id, "label": label});
    });
  }

  Future<void> _aiFormalize() async {
    if (bodyController.text.isEmpty) return;
    setState(() => isAiLoading = true);
    try {
      final res = await _api.post("/api/v2/admin/notifications/ai/formalize", {
        "text": bodyController.text,
      });
      setState(() => bodyController.text = res["data"]["formalized"]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => isAiLoading = false);
    }
  }

  Future<void> _aiTranslate(String lang) async {
    if (bodyController.text.isEmpty) return;
    setState(() => isAiLoading = true);
    try {
      final res = await _api.post("/api/v2/admin/notifications/ai/translate", {
        "text": bodyController.text,
        "lang": lang,
      });
      setState(
        () => bodyController.text +=
            "\n\n$lang Content:\n${res["data"]["translated"]}",
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => isAiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    "🎯 Selection Hub",
                    "Who should receive this message?",
                  ),
                  const SizedBox(height: 16),
                  _buildRecipientsGrid(),
                  if (targets.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildActiveTargets(),
                  ],
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    "📝 Message Studio",
                    "Compose your announcement with AI assistance",
                  ),
                  const SizedBox(height: 16),
                  _buildMessageEditor(),
                  const SizedBox(height: 24),
                  _buildAiToolbar(),
                  const SizedBox(height: 24),
                  _buildExpirySelector(),
                  const SizedBox(height: 32),
                  _buildSendButton(),
                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    "📜 Notification History",
                    "Manage and delete sent notifications",
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationHistory(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Notify Hub",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A4DFF), Color(0xFF0031D1)],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E263E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientsGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTargetChip("🌍 Whole School", () {
          _addTarget('role', 'student', 'Students');
          _addTarget('role', 'teacher', 'Teachers');
        }),
        _buildTargetChip(
          "🎓 All Students",
          () => _addTarget('role', 'student', 'Students'),
        ),
        _buildTargetChip(
          "👩‍🏫 All Teachers",
          () => _addTarget('role', 'teacher', 'Teachers'),
        ),
        _buildTargetChip(
          "💳 Fee Defaulters",
          () => _addTarget('group', 'fee_defaulters', 'Defaulters'),
        ),
        ...sections.map(
          (s) => _buildTargetChip(
            "📚 Sec ${s["class"]}-${s["section"]}",
            () =>
                _addTarget('section', s["id"], "${s["class"]}-${s["section"]}"),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetChip(String label, VoidCallback onPressed) {
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.blue.withOpacity(0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      label: Text(label),
      labelStyle: const TextStyle(
        color: Color(0xFF1E263E),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildActiveTargets() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withOpacity(0.1)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: targets
            .map(
              (t) => Chip(
                onDeleted: () => setState(() => targets.remove(t)),
                backgroundColor: const Color(0xFF1A4DFF),
                deleteIconColor: Colors.white70,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                label: Text(t["label"]),
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMessageEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Headline (e.g. 📢 School Holiday)",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.title_rounded,
                color: Color(0xFF1A4DFF),
              ),
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          TextField(
            controller: bodyController,
            maxLines: 8,
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: InputDecoration(
              hintText: "Type your announcement or use AI to draft...",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
              suffixIcon: isAiLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiToolbar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "✨ AI Smart Tools",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.blueGrey.shade600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAiButton("👔 Formalize", _aiFormalize),
              const SizedBox(width: 8),
              _buildAiButton("🇮🇳 Telugu", () => _aiTranslate('Telugu')),
              const SizedBox(width: 8),
              _buildAiButton("🕉️ Hindi", () => _aiTranslate('Hindi')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1A4DFF),
        side: const BorderSide(color: Color(0xFF1A4DFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4DFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A4DFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _handleSend,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded),
            SizedBox(width: 12),
            Text(
              "Launch Announcement",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (targets.isEmpty ||
        titleController.text.isEmpty ||
        bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select recipients and fill message details"),
        ),
      );
      return;
    }
    try {
      final res = await _api.post("/api/v2/admin/notifications/send", {
        "title": titleController.text,
        "body": bodyController.text,
        "targets": targets,
        "expires_at": expiryDate?.toIso8601String(),
      });
      if (res["success"]) {
        titleController.clear();
        bodyController.clear();
        setState(() {
          targets = [];
          expiryDate = null;
        });
        _fetchHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚀 Announcement sent successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Widget _buildExpirySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Expiration Date (Optional)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  expiryDate == null
                      ? "Persistent forever"
                      : "Expires on ${DateFormat('MMM d, yyyy').format(expiryDate!)}",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => expiryDate = picked);
            },
            child: Text(expiryDate == null ? "Set" : "Change"),
          ),
          if (expiryDate != null)
            IconButton(
              onPressed: () => setState(() => expiryDate = null),
              icon: const Icon(Icons.clear, size: 18, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await _api.get("/api/v2/admin/notifications");
      setState(() => sharedNotifications = res["data"] ?? []);
    } catch (e) {}
  }

  Future<void> _deleteNotif(int id) async {
    try {
      await _api.delete("/api/v2/admin/notifications/$id");
      _fetchHistory();
    } catch (e) {}
  }

  Widget _buildNotificationHistory() {
    if (sharedNotifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "No history available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sharedNotifications.length,
      itemBuilder: (context, index) {
        final n = sharedNotifications[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            title: Text(
              n["title"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              n["expires_at"] != null
                  ? "Expires: ${DateFormat('MMM d').format(DateTime.parse(n["expires_at"]))}"
                  : "No expiry",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _deleteNotif(n["id"]),
            ),
          ),
        );
      },
    );
  }
}
