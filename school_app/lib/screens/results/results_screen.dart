import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  bool _loading = true;
  List<dynamic> _allResults = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      final res = await _api.get("/api/v1/results/my");
      if (mounted) {
        setState(() {
          _allResults = res["data"] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offlineResults = _allResults.where((r) => r['class'] != 'Online').toList();
    final onlineResults = _allResults.where((r) => r['class'] == 'Online').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildResultsList(offlineResults, "Offline"),
                      _buildResultsList(onlineResults, "Online Portal"),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                style: IconButton.styleFrom(backgroundColor: Colors.white12),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "RESULT HUB",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(width: 45), // Balance for back button
            ],
          ),
          const SizedBox(height: 25),
          _buildStatsSummary(),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total Exams", _allResults.length.toString()),
          _verticalDivider(),
          _summaryItem("Avg Score", _calculateAvg()),
          _verticalDivider(),
          _summaryItem("Performance", "Excellent"),
        ],
      ),
    );
  }

  String _calculateAvg() {
    if (_allResults.isEmpty) return "0%";
    double sum = 0;
    int count = 0;
    for (var r in _allResults) {
      if (r['marks'] != null && r['total_marks'] != null) {
        sum += (r['marks'] / r['total_marks']) * 100;
        count++;
      }
    }
    return count > 0 ? "${(sum / count).toStringAsFixed(1)}%" : "N/A";
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade400,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        tabs: const [
          Tab(text: "OFFLINE EXAMS"),
          Tab(text: "ONLINE PORTAL"),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<dynamic> results, String type) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 15),
            Text("No $type results found", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
    }

    // Group by exam name
    Map<String, List<dynamic>> grouped = {};
    for (var item in results) {
      String exam = item["exam"] ?? "Standard Exam";
      if (!grouped.containsKey(exam)) grouped[exam] = [];
      grouped[exam]!.add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        String examName = grouped.keys.elementAt(index);
        List<dynamic> subjects = grouped[examName]!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              _buildExamHeader(examName, subjects[0]),
              ...subjects.map((s) => _buildSubjectRow(s)),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamHeader(String name, dynamic info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF4F46E5), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(
                  info["exam_date"] != null 
                    ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(info["exam_date"]))
                    : "Published",
                  style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectRow(dynamic s) {
    double perc = (s['marks'] ?? 0) / (s['total_marks'] ?? 100) * 100;
    Color gradeColor = perc > 75 ? Colors.green : (perc > 50 ? Colors.blue : Colors.orange);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: gradeColor.withOpacity(0.1),
            child: Icon(Icons.circle, size: 8, color: gradeColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s["subject"] ?? "General", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
                Text(s["remarks"] ?? "Good Effort", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${s['marks']}/${s['total_marks']}",
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1E293B)),
              ),
              Text(
                "${perc.toStringAsFixed(0)}%",
                style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
