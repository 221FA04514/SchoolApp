import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();

  bool loading = true;
  List results = [];

  late AnimationController _pageController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    fetchResults();

    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _pageController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchResults() async {
    final res = await api.get("/api/v1/results/my");

    setState(() {
      results = res["data"];
      loading = false;
    });

    _pageController.forward();
  }

  // 🎨 SUBJECT COLOR (UI ONLY)
  Color _subjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains("math")) return Colors.blue;
    if (s.contains("science")) return Colors.green;
    if (s.contains("english")) return Colors.purple;
    if (s.contains("social")) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (results.isEmpty && !loading) {
      return const Scaffold(
        body: Center(child: Text("📭 No results available")),
      );
    }

    // 📊 SUMMARY CALCULATION (UI ONLY)
    final marksList =
        results.map((r) => r["marks"] as int).toList();
    final highest = marksList.reduce((a, b) => a > b ? a : b);
    final average =
        (marksList.reduce((a, b) => a + b) / marksList.length)
            .toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ================= HEADER =================
                SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      height: size.height * 0.22,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1A4DFF),
                            Color(0xFF3A6BFF),
                            Color(0xFF6A11CB),
                          ],
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(28),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: const [
                            BackButton(color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "🏆 Results",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ================= CONTENT =================
                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // ================= SUMMARY CARD =================
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF43CEA2),
                                  Color(0xFF185A9D),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryItem(
                                  label: "Subjects",
                                  value: results.length.toString(),
                                  emoji: "📚",
                                ),
                                _SummaryItem(
                                  label: "Highest",
                                  value: "$highest",
                                  emoji: "🏆",
                                ),
                                _SummaryItem(
                                  label: "Average",
                                  value: average,
                                  emoji: "📈",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ================= RESULT LIST =================
                          ...List.generate(results.length, (index) {
                            final r = results[index];
                            final isTop = r["marks"] == highest;
                            final color =
                                _subjectColor(r["subject"]);

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                  milliseconds: 500 + index * 120),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset:
                                        Offset(0, 30 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(18),
                                  border: isTop
                                      ? Border.all(
                                          color: Colors.amber,
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Text(
                                    "📘",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: color,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${r["subject"]} — ${r["marks"]} marks",
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (isTop)
                                        const Text("🏆"),
                                    ],
                                  ),
                                  subtitle: Text(
                                    "📝 ${r["exam"]}\n🗓️ ${r["exam_date"].toString().split('T')[0]}",
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ================= SUMMARY ITEM =================
class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
