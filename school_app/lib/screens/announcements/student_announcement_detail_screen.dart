import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';

class StudentAnnouncementDetailScreen extends StatefulWidget {
  final int announcementId;

  const StudentAnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<StudentAnnouncementDetailScreen> createState() =>
      _StudentAnnouncementDetailScreenState();
}

class _StudentAnnouncementDetailScreenState
    extends State<StudentAnnouncementDetailScreen> {
  final ApiService _api = ApiService();
  Map announcement = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncement();
  }

  Future<void> fetchAnnouncement() async {
    try {
      final res = await _api.get(
        "/api/v1/announcements/${widget.announcementId}",
      );
      if (mounted) {
        setState(() {
          announcement = res["data"];
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load announcement")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(20.0),
                  sliver: SliverToBoxAdapter(child: _buildDetailsCard()),
                ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF4A00E0),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const BackButton(color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text(
          "Notice Detail",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
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
                  colors: [Color(0xFF4A00E0), Color(0xFF6A11CB)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.03),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    String emoji = "📢";
    final title = announcement["title"].toString().toLowerCase();
    if (title.contains("exam") || title.contains("test")) emoji = "📝";
    if (title.contains("holiday") || title.contains("circular")) emoji = "🗓️";
    if (title.contains("homework")) emoji = "📚";
    if (title.contains("fee")) emoji = "💳";
    if (title.contains("event") || title.contains("republic")) emoji = "🎉";

    String postDate = "";
    try {
      final date = DateTime.parse(announcement["created_at"]);
      postDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    } catch (e) {}

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Text(
                  "OFFICIAL NOTICE",
                  style: TextStyle(
                    color: Color(0xFF4A00E0),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            announcement["title"],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E263E),
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 32, color: Colors.grey.shade100),
          Text(
            announcement["description"],
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueGrey.shade700,
              height: 1.7,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4A00E0).withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF4A00E0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "POSTED BY",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            announcement["creator_name"] ?? "School Administration",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E263E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF4A00E0),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "POSTED ON",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey.shade400,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            postDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E263E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
