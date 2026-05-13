import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_service.dart';
import './teacher_detail_screen.dart';

class TeacherFacultyDirectoryScreen extends StatefulWidget {
  const TeacherFacultyDirectoryScreen({super.key});

  @override
  State<TeacherFacultyDirectoryScreen> createState() => _TeacherFacultyDirectoryScreenState();
}

class _TeacherFacultyDirectoryScreenState extends State<TeacherFacultyDirectoryScreen> {
  final ApiService _api = ApiService();
  final searchController = TextEditingController();
  List teachers = [];
  List filteredTeachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      filteredTeachers = teachers.where((t) {
        final name = t["name"].toString().toLowerCase();
        final subject = t["subject"].toString().toLowerCase();
        final search = searchController.text.toLowerCase();
        return name.contains(search) || subject.contains(search);
      }).toList();
    });
  }

  Future<void> _fetchTeachers() async {
    setState(() => isLoading = true);
    try {
      final res = await _api.get("/api/v1/admin/teachers");
      if (mounted) {
        setState(() {
          teachers = res["data"] ?? [];
          filteredTeachers = teachers;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildFacultyCard(filteredTeachers[index]),
                      childCount: filteredTeachers.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      backgroundColor: const Color(0xFF4A00E0),
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
          "Faculty Directory",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF673AB7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: "Search faculty by name or subject...",
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: Color(0xFF4A00E0)),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(Map t) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherDetailScreen(teacher: t))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF4A00E0).withOpacity(0.1),
                    child: Text(
                      (t["name"]?[0] ?? "F").toUpperCase(),
                      style: const TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t["name"] ?? "Faculty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(t["subject"] ?? "General", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildCallBtn(t["phone"]),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Qual: ${t["qualification"] ?? "N/A"}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TeacherDetailScreen(teacher: t))),
                    child: const Text("View Profile", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A00E0))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallBtn(String? phone) {
    return IconButton(
      icon: const Icon(Icons.call_rounded, color: Colors.green),
      onPressed: () async {
        if (phone == null || phone.isEmpty) return;
        final url = Uri.parse('tel:$phone');
        if (await canLaunchUrl(url)) await launchUrl(url);
      },
    );
  }
}
