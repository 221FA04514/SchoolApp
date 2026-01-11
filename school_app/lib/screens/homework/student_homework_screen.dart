import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../models/homework_model.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool loading = true;
  List<Homework> homeworkList = [];

  // Animation
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fetchHomework();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> fetchHomework() async {
    try {
      final res = await _api.get("/api/v1/homework/student");
      if (mounted) {
        setState(() {
          homeworkList = (res["data"] as List)
              .map((h) => Homework.fromJson(h))
              .toList();
          loading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleHomeworkStatus(Homework hw) async {
    // Optimistic Update
    setState(() {
      hw.isCompleted = !hw.isCompleted;
    });

    try {
      await _api.post("/api/v1/homework/status", {
        "homework_id": hw.id,
        "is_completed": hw.isCompleted,
      });
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() {
          hw.isCompleted = !hw.isCompleted;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update status: $e")));
      }
    }
  }

  // Helper to get subject color
  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathematics':
        return const Color(0xFF4ea1ff); // Blue
      case 'science':
      case 'physics':
      case 'chemistry':
        return const Color(0xFF43cea2); // Green
      case 'history':
      case 'social':
        return const Color(0xFFffb347); // Orange
      case 'english':
        return const Color(0xFFff758c); // Pinkish Red
      case 'computer':
        return const Color(0xFF9d50bb); // Purple
      default:
        return const Color(0xFF757f9a); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // ================= HEADER BACKGROUND =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1fa2ff),
                    Color(0xFF12d8fa),
                    Color(0xFFa6ffcb),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),

          // ================= BODY =================
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------ APP BAR ------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                        "My Homework",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // ------ DASHBOARD CONTENT ------
                const SizedBox(height: 10),

                // Tracker Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(child: _buildProgressCard()),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : homeworkList.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 20,
                            top: 10, // Added top padding
                          ),
                          itemCount: homeworkList.length,
                          itemBuilder: (context, index) {
                            final hw = homeworkList[index];
                            return _buildHomeworkCard(hw, index);
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

  Widget _buildProgressCard() {
    final total = homeworkList.length;
    final completed = homeworkList.where((h) => h.isCompleted).length;
    final percent = total == 0 ? 0.0 : completed / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // CIRCULAR INDICATOR
          SizedBox(
            height: 60,
            width: 60,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF43CEA2),
                      ),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // TEXT SUMMARY
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Homework Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$completed of $total Tasks Completed",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No Homework Assigned",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(Homework hw, int index) {
    // Staggered Animation
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutBack,
      ),
    );

    final subjectColor = _getSubjectColor(hw.subject);
    final isDone = hw.isCompleted;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: () {
            // Show details
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(hw.title),
                content: Text(hw.description),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDone ? Colors.white.withOpacity(0.9) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDone
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CARD HEADER (Subject + Date) ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.grey.shade100
                        : subjectColor.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.grey.shade400 : subjectColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hw.subject.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDone ? Colors.grey : subjectColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Due: ${hw.dueDate.toIso8601String().split('T')[0]}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.grey : subjectColor,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- CARD BODY ---
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // CHECKBOX
                      GestureDetector(
                        onTap: () => _toggleHomeworkStatus(hw),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32, // Larger touch target
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDone
                                ? const Color(0xFF43CEA2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Rounded rect
                            border: Border.all(
                              color: isDone
                                  ? const Color(0xFF43CEA2)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: isDone
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF43CEA2,
                                      ).withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: isDone
                              ? const Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hw.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? Colors.grey.shade400
                                    : Colors.black87,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hw.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                                height: 1.4,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
