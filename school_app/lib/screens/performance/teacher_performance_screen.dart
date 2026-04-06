import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class TeacherPerformanceScreen extends StatefulWidget {
  const TeacherPerformanceScreen({super.key});

  @override
  State<TeacherPerformanceScreen> createState() =>
      _TeacherPerformanceScreenState();
}

class _TeacherPerformanceScreenState extends State<TeacherPerformanceScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List sections = [];
  List students = [];
  List filteredStudents = [];

  int? selectedSectionId;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchSections();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSections() async {
    try {
      final res = await _api.get("/api/v1/sections");
      if (mounted) {
        setState(() => sections = res["data"]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching sections: $e")));
      }
    }
  }

  Future<void> fetchStudents() async {
    if (selectedSectionId == null) return;

    setState(() => loading = true);

    try {
      final res = await _api.get(
        "/api/v1/attendance/students?section_id=$selectedSectionId",
      );

      setState(() {
        students = res["data"];
        filteredStudents = List.from(students);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching students: $e")));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredStudents = students.where((s) {
        return s["name"].toLowerCase().contains(query) ||
            s["roll_number"].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showEvaluationSheet(Map student) {
    String selectedRating = 'Good';
    TextEditingController remarksController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Evaluate: ${student["name"]}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Performance Rating",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRatingButton(
                        label: 'Good',
                        color: Colors.green,
                        icon: Icons.thumb_up,
                        isSelected: selectedRating == 'Good',
                        onTap: () =>
                            setModalState(() => selectedRating = 'Good'),
                      ),
                      _buildRatingButton(
                        label: 'Need to improve',
                        color: Colors.orange,
                        icon: Icons.trending_up,
                        isSelected: selectedRating == 'Need to improve',
                        onTap: () => setModalState(
                          () => selectedRating = 'Need to improve',
                        ),
                      ),
                      _buildRatingButton(
                        label: 'Bad',
                        color: Colors.red,
                        icon: Icons.thumb_down,
                        isSelected: selectedRating == 'Bad',
                        onTap: () =>
                            setModalState(() => selectedRating = 'Bad'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter remarks (optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            setModalState(() => isSubmitting = true);
                            try {
                              await _api.post("/api/v1/performance", {
                                "student_id": student["student_id"],
                                "performance_rating": selectedRating,
                                "remarks": remarksController.text,
                              });
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Performance submitted!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              setModalState(() => isSubmitting = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF4A00E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Submit Evaluation",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRatingButton({
    required String label,
    required Color color,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Stack(
        children: [
          // Curved Header Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4A00E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const BackButton(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        "Student Performance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A00E0).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: selectedSectionId,
                            hint: const Text("Select Section"),
                            isExpanded: true,
                            items: sections.map<DropdownMenuItem<int>>((s) {
                              return DropdownMenuItem(
                                value: s["id"],
                                child: Text(s["name"]),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedSectionId = val;
                                students.clear();
                                filteredStudents.clear();
                              });
                              fetchStudents();
                            },
                          ),
                        ),
                        const Divider(),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search student...",
                            border: InputBorder.none,
                            icon: Icon(Icons.search,
                                color: Color(0xFF4A00E0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredStudents.isEmpty
                          ? const Center(child: Text("No students found"))
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(
                                        0xFF4A00E0,
                                      ).withOpacity(0.1),
                                      child: Text(
                                        student["name"][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF4A00E0),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      student["name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle:
                                        Text("Roll: ${student["roll_number"]}"),
                                    trailing: ElevatedButton(
                                      onPressed: () =>
                                          _showEvaluationSheet(student),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF4A00E0,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text("Evaluate"),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
