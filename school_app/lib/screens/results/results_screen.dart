import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService api = ApiService();

  bool loading = true;
  List results = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  Future<void> fetchResults() async {
    final res = await api.get("/api/v1/results/my");

    setState(() {
      results = res["data"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text("No results available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(
                          "${r["subject"]} - ${r["marks"]} marks",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${r["exam"]} • ${r["exam_date"].toString().split('T')[0]}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
