import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final ApiService _api = ApiService();
  List notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final res = await _api.get("/api/v1/notifications");
      final subRes = await _api.get("/api/v2/admin/substitutions/my-today");
      final adminRes = await _api.get("/api/v2/admin/notifications/my");
      
      if (mounted) {
        setState(() {
          final regularNotifs = res["data"] ?? [];
          final substitutions = (subRes["data"] as List? ?? []).map((s) {
            final cls = s['class_name']?.toString() ?? 'N/A';
            final sec = s['section_name']?.toString() ?? 'N/A';
            final teacher = s['original_teacher']?.toString() ?? 'Colleague';
            final period = s['period']?.toString() ?? '?';
            
            return {
              ...s,
              "id": "sub_${s['id']}", // Virtual ID
              "title": "📋 Substitution Assigned",
              "body": "Covering for $teacher in Class $cls-$sec (Period $period)",
              "type": "substitution",
              "created_at": DateTime.now().toIso8601String(),
              "is_read": 0
            };
          }).toList();

          final adminNotifs = (adminRes["data"] as List? ?? []).map((n) {
            return {
              ...n,
              "id": "admin_${n['id']}",
              "title": n["title"] ?? "Admin Update",
              "body": n["body"] ?? n["message"] ?? "",
              "type": "admin",
              "is_read": n["receipt_status"] == 'read' ? 1 : 0,
            };
          }).toList();

          notifications = [...substitutions, ...adminNotifs, ...regularNotifs];
          
          // Sort by date (descending)
          notifications.sort((a, b) {
            final dateA = DateTime.tryParse(a["created_at"].toString()) ?? DateTime(2000);
            final dateB = DateTime.tryParse(b["created_at"].toString()) ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _api.patch("/api/v1/notifications/$id/read", {});
      if (mounted) {
        setState(() {
          final idx = notifications.indexWhere((n) => n["id"] == id);
          if (idx != -1) notifications[idx]["is_read"] = 1;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildNotificationList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const BackButton(color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 72, bottom: 20),
        title: const Text(
          "Notifications Hub",
          style: TextStyle(
            fontWeight: FontWeight.w900,
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
            // Decorative icon
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 180,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "All caught up!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
            const Text(
              "No new notifications from the office.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final n = notifications[index];
            final isUnread = (n["is_read"] == 0 || n["is_read"] == false);
            return _buildNotificationCard(n, isUnread);
          },
          childCount: notifications.length,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map n, bool isUnread) {
    String timeLabel = "";
    try {
      final date = DateTime.parse(n["created_at"]).toLocal();
      timeLabel = DateFormat('MMM d, h:mm a').format(date);
    } catch (e) {}

    final bool isSubstitution = (n['type'] ?? '') == 'substitution';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: isSubstitution
            ? Border.all(
                color: Colors.cyanAccent.withOpacity(0.3), width: 1.5)
            : isUnread
                ? Border.all(
                    color: const Color(0xFF1A4DFF).withOpacity(0.1), width: 1.5)
                : Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: isSubstitution
                ? Colors.cyanAccent.withOpacity(0.08)
                : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isUnread) _markAsRead(n["id"]);
            _showNotificationDetail(n);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Substitution: left accent bar
                if (isSubstitution)
                  Container(
                    width: 4,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12, top: 2),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                if (isUnread && !isSubstitution)
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A4DFF),
                      shape: BoxShape.circle,
                    ),
                  )
                else if (!isSubstitution)
                  const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Substitution badge label
                      if (isSubstitution) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz_rounded,
                                  size: 11,
                                  color: Colors.cyanAccent.shade700),
                              SizedBox(width: 4),
                              Text(
                                'SUBSTITUTION DUTY',
                                style: TextStyle(
                                  color: Colors.cyanAccent.shade700,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Text(
                        n["title"] ?? "",
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: -0.3,
                          color: isSubstitution
                              ? Colors.cyanAccent.shade700
                              : const Color(0xFF1E263E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        n["body"] ?? "",
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.blueGrey.shade700,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blueGrey.shade300,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(Map n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              n["title"] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E263E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              n["body"] ?? "",
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A4DFF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Close",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
