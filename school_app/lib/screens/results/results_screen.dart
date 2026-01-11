import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  final ApiService api = ApiService();

  bool loading = true;
  Map<String, List<dynamic>> groupedResults = {};

  // Stats
  int totalSubjects = 0;
  int highestMark = 0;
  double averageMark = 0.0;

  late AnimationController _pageController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    fetchResults();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _pageController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    try {
      final res = await api.get("/api/v1/results/my");
      final List results = res["data"] ?? [];

      if (results.isNotEmpty) {
        // Grouping logic
        Map<String, List<dynamic>> groups = {};
        int max = 0;
        int total = 0;
        int count = 0;

        for (var r in results) {
          final examName = r["exam"] ?? "Other";
          if (!groups.containsKey(examName)) {
            groups[examName] = [];
          }
          groups[examName]!.add(r);

          final marks = r["marks"] as int;
          if (marks > max) max = marks;
          total += marks;
          count++;
        }

        setState(() {
          groupedResults = groups;
          highestMark = max;
          totalSubjects = count;
          averageMark = count > 0 ? total / count : 0.0;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
    _pageController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          // ================= HEADER =================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
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

          // ================= CONTENT =================
          SafeArea(
            child: Column(
              children: [
                // APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                        "My Results",
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

                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : groupedResults.isEmpty
                      ? const Center(
                          child: Text(
                            "📭 No results available",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : FadeTransition(
                          opacity: _fade,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                            child: Column(
                              children: [
                                // ✨ SUMMARY CARD
                                _buildSummaryCard(),
                                const SizedBox(height: 24),

                                // 📋 EXAM CARDS
                                ...groupedResults.entries.map((entry) {
                                  return _buildExamCard(entry.key, entry.value);
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryStat("Total", totalSubjects.toString(), "📚", Colors.blue),
          _divider(),
          _summaryStat("Highest", highestMark.toString(), "🏆", Colors.amber),
          _divider(),
          _summaryStat(
            "Average",
            averageMark.toStringAsFixed(1),
            "📈",
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
  }

  Widget _summaryStat(String label, String value, String emoji, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard(String examName, List<dynamic> subjects) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Exam Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1fa2ff).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF1fa2ff),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  examName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  "${subjects.length} Subjects",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Subject List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: subjects.map((s) {
                final double score = (s["marks"] as int).toDouble();
                final isHighest = s["marks"] == highestMark;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _getScoreColor(score).withOpacity(0.1),
                        child: Text(
                          s["subject"][0].toUpperCase(),
                          style: TextStyle(
                            color: _getScoreColor(score),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s["subject"],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (isHighest)
                              const Text(
                                "Top Scorer 🏆",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${s["marks"]}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                          const Text(
                            "Marks",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Footer / Date
          Padding(
            padding: const EdgeInsets.only(bottom: 12, right: 20),
            child: Text(
              "Date: ${subjects[0]["exam_date"].toString().split('T')[0]}",
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF43CEA2); // High
    if (score >= 40) return const Color(0xFF1fa2ff); // Average
    return const Color(0xFFFF5F6D); // Low
  }
}
