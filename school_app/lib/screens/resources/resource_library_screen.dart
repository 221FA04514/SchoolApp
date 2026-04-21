import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({super.key});

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  final ApiService _api = ApiService();
  late Future<List<dynamic>> _resourcesFuture;
  String _selectedSubject = "All";
  List<String> _subjects = ["All"];

  @override
  void initState() {
    super.initState();
    _resourcesFuture = _fetchResources();
  }

  Future<List<dynamic>> _fetchResources() async {
    final res = await _api.get("/api/v1/resources");
    final List<dynamic> data = res["data"];

    // Extract unique subjects
    final Set<String> subjectSet = {"All"};
    for (var r in data) {
      if (r["subject"] != null) {
        subjectSet.add(r["subject"]);
      }
    }

    setState(() {
      _subjects = subjectSet.toList()..sort();
    });

    return data;
  }

  Future<void> _downloadAndOpenFile(Map<String, dynamic> resource) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF4A00E0)),
                SizedBox(height: 20),
                Text(
                  "Preparing Secure Download...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  "Optimizing for your device",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );

      final fileName = resource["file_url"].split('/').last;
      final fullUrl = "${AppConstants.baseUrl}${resource["file_url"]}";
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/$fileName";

      final dio = Dio();
      await dio.download(fullUrl, filePath);

      if (mounted) Navigator.pop(context);

      final Uri fileUri = Uri.file(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: const Color(0xFF1E293B),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              const SizedBox(width: 10),
              Expanded(child: Text("Successfully Saved: $fileName")),
            ],
          ),
          action: SnackBarAction(
            label: "OPEN",
            textColor: Colors.blueAccent,
            onPressed: () async {
              if (await canLaunchUrl(fileUri)) {
                await launchUrl(fileUri);
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildPremiumHeader(),
          SliverToBoxAdapter(child: _buildCategoryBar()),
          _buildResourceList(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF4A00E0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF6B11CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.library_books_rounded,
                    size: 200,
                    color: Colors.white,
                  ),
                ),
              ),
              const Positioned(
                bottom: 25,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Digital Library",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      "Access your academic resources instantly",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final s = _subjects[index];
          final isSelected = _selectedSubject == s;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(s),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedSubject = s),
              selectedColor: const Color(0xFF4A00E0),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide.none,
              ),
              elevation: isSelected ? 4 : 0,
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourceList() {
    return FutureBuilder<List<dynamic>>(
      future: _resourcesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];
        final filteredData = _selectedSubject == "All"
            ? data
            : data.where((r) => r["subject"] == _selectedSubject).toList();

        if (filteredData.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text(
                "No resources in this category",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final r = filteredData[index];
              return _buildResourceCard(r);
            }, childCount: filteredData.length),
          ),
        );
      },
    );
  }

  Widget _buildResourceCard(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _downloadAndOpenFile(r),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A00E0).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIcon(r["type"]),
                    color: const Color(0xFF4A00E0),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r["title"],
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${r["subject"]} • Chapter Content",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    type = type?.toLowerCase();
    if (type == "pdf") return Icons.picture_as_pdf_rounded;
    if (type == "mp4" || type == "mov") return Icons.video_library_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
