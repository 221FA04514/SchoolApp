import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_service.dart';
import './student_detail_screen.dart';

class TeacherStudentDirectoryScreen extends StatefulWidget {
  const TeacherStudentDirectoryScreen({super.key});

  @override
  State<TeacherStudentDirectoryScreen> createState() => _TeacherStudentDirectoryScreenState();
}

class _TeacherStudentDirectoryScreenState extends State<TeacherStudentDirectoryScreen> {
  final ApiService _api = ApiService();
  final searchController = TextEditingController();
  
  List students = [];
  List filteredStudents = [];
  List sections = [];
  List<String> classes = [];
  
  String selectedClass = "All";
  String selectedSection = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final sRes = await _api.get("/api/v1/admin/students");
      final secRes = await _api.get("/api/v1/admin/sections");
      if (mounted) {
        final secData = secRes["data"] ?? [];
        final classSet = <String>{};
        for (var s in secData) {
          classSet.add(s["class"].toString());
        }
        
        setState(() {
          students = sRes["data"] ?? [];
          sections = secData;
          classes = classSet.toList()..sort((a, b) {
            final aNum = int.tryParse(a) ?? 0;
            final bNum = int.tryParse(b) ?? 0;
            return aNum.compareTo(bNum);
          });

          filteredStudents = students;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStudents = students.where((s) {
        final matchesClass = selectedClass == "All" || s["class"].toString() == selectedClass;
        final matchesSection = selectedSection == "All" || s["section_name"] == selectedSection;
        final name = (s["name"] ?? "").toString().toLowerCase();
        final search = searchController.text.toLowerCase();
        return matchesClass && matchesSection && name.contains(search);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildFilters()),
          isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : filteredStudents.isEmpty
                  ? const SliverFillRemaining(child: Center(child: Text("No students found", style: TextStyle(color: Colors.grey))))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildStudentCard(filteredStudents[index]),
                          childCount: filteredStudents.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
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
        titlePadding: const EdgeInsets.only(left: 72, bottom: 16),
        title: const Text(
          "Student Directory",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20),
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

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search by student name...",
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4A00E0)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        _filterLabel("Select Class"),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPill("All", selectedClass, (val) {
                setState(() {
                  selectedClass = val;
                  selectedSection = "All"; 
                  _applyFilters();
                });
              }),
              ...classes.map((c) => _buildPill(c, selectedClass, (val) {
                setState(() {
                  selectedClass = val;
                  selectedSection = "All";
                  _applyFilters();
                });
              }, prefix: "Class ")),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _filterLabel("Select Section"),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildPill("All", selectedSection, (val) {
                setState(() {
                  selectedSection = val;
                  _applyFilters();
                });
              }),
              ...sections
                  .where((sec) => selectedClass == "All" || sec["class"].toString() == selectedClass)
                  .map((sec) => _buildPill(sec["name"].toString(), selectedSection, (val) {
                        setState(() {
                          selectedSection = val;
                          _applyFilters();
                        });
                      }, prefix: "Section ")),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _filterLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPill(String label, String current, Function(String) onTap, {String prefix = ""}) {
    final isSelected = current == label;
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A00E0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Center(
          child: Text(
            label == "All" ? "All" : "$prefix$label",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map s) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A00E0).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (s["name"]?[0] ?? "S").toUpperCase(),
                        style: const TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s["name"] ?? "Student",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.school_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              "Class ${s["class"] ?? "-"} • Section ${s["section_name"] ?? "N/A"}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A00E0).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Roll: ${s["roll_number"] ?? "-"}",
                      style: const TextStyle(color: Color(0xFF4A00E0), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailScreen(student: s))),
                    icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF4A00E0)),
                    label: const Text("See Profile", style: TextStyle(color: Color(0xFF4A00E0), fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      _buildSmallActionBtn(
                        Icons.call_rounded,
                        Colors.green,
                        () => _launchCaller(s["parent_phone"] ?? s["phone"]),
                        "Call",
                      ),
                      const SizedBox(width: 8),
                      _buildSmallActionBtn(
                        Icons.message_rounded,
                        Colors.blue,
                        () => _launchSms(s["parent_phone"] ?? s["phone"]),
                        "SMS",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, Color color, VoidCallback onTap, String label) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

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
}
