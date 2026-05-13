import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherDetailScreen extends StatelessWidget {
  final Map teacher;

  const TeacherDetailScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPrimaryInfoCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Faculty Contact Information"),
                  const SizedBox(height: 12),
                  _buildContactCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Academic Specialization"),
                  const SizedBox(height: 12),
                  _buildAcademicCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF673AB7),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const BackButton(color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          teacher["name"] ?? "Teacher Profile",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.person_pin_rounded,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildPrimaryInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFF673AB7).withOpacity(0.1),
            child: Text(
              (teacher["name"]?[0] ?? "T").toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            teacher["name"] ?? "Unknown",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              teacher["subject"] ?? "General Faculty",
              style: TextStyle(
                fontSize: 12,
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionBtn(Icons.call_rounded, Colors.green, () => _launchCaller(teacher["phone"])),
              const SizedBox(width: 20),
              _buildActionBtn(Icons.message_rounded, Colors.blue, () => _launchSms(teacher["phone"])),
              const SizedBox(width: 20),
              _buildActionBtn(Icons.email_rounded, Colors.orange, () => _launchEmail(teacher["email"])),
            ],
          ),
          if (teacher["address"] != null && teacher["address"].isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildInfoTile(Icons.location_on_rounded, "Current Address", teacher["address"], Colors.redAccent),
          ],

        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.phone_iphone_rounded, "Mobile Number", teacher["phone"] ?? "Not Provided", Colors.blue),
          _divider(),
          _buildInfoTile(Icons.alternate_email_rounded, "Email Address", teacher["email"] ?? "Not Provided", Colors.orange),
          _divider(),
          _buildInfoTile(Icons.calendar_today_rounded, "Date of Birth", teacher["dob"] ?? "Not Provided", Colors.pink),
        ],
      ),
    );

  }

  Widget _buildAcademicCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.auto_stories_rounded, "Specialization", teacher["subject"] ?? "N/A", Colors.indigo),
          _divider(),
          _buildInfoTile(Icons.school_rounded, "Qualification", teacher["qualification"] ?? "N/A", Colors.purple),
          _divider(),
          _buildInfoTile(Icons.work_rounded, "Experience", teacher["experience"] ?? "N/A", Colors.blueGrey),
          _divider(),
          _buildInfoTile(Icons.event_available_rounded, "Joining Date", teacher["joining_date"] ?? "N/A", Colors.orange),
          _divider(),
          _buildInfoTile(Icons.history_rounded, "Member Since", teacher["created_at"] != null ? teacher["created_at"].toString().split('T')[0] : "N/A", Colors.teal),
        ],
      ),
    );

  }

  Widget _buildInfoTile(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, indent: 60, endIndent: 16, color: Colors.grey.shade100);

  void _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchSms(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('sms:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchEmail(String? email) async {
    if (email == null || email.isEmpty) return;
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
