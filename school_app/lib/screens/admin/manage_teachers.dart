import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';

class ManageTeachersScreen extends StatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  State<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends State<ManageTeachersScreen> {
  final ApiService _api = ApiService();
  final searchController = TextEditingController();
  List teachers = [];
  List filteredTeachers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  // Theme Color
  final Color primaryColor = const Color(0xFF673AB7); // Deep Purple

  @override
  void initState() {
    super.initState();
    fetchTeachers();
<<<<<<< HEAD
    searchController.addListener(_onSearchChanged);
=======
    searchController.addListener(_filterTeachers);
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  void _onSearchChanged() {
    setState(() {
      filteredTeachers = teachers.where((t) {
        final name = t["name"].toString().toLowerCase();
        final subject = t["subject"].toString().toLowerCase();
        final search = searchController.text.toLowerCase();
        return name.contains(search) || subject.contains(search);
=======
  void _filterTeachers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredTeachers = teachers.where((t) {
        final name = (t["name"] ?? "").toLowerCase();
        final subject = (t["subject"] ?? "").toLowerCase();
        return name.contains(query) || subject.contains(query);
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
      }).toList();
    });
  }

  Future<void> fetchTeachers() async {
    try {
      final res = await _api.get("/api/v1/admin/teachers");
<<<<<<< HEAD
      setState(() {
        teachers = res["data"] ?? [];
        filteredTeachers = teachers;
        isLoading = false;
      });
=======
      if (mounted) {
        setState(() {
          teachers = res["data"] ?? [];
          filteredTeachers = teachers;
          isLoading = false;
        });
      }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
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
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final t = filteredTeachers[index];
                      return _buildTeacherCard(t);
                    }, childCount: filteredTeachers.length),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTeacherDialog,
        backgroundColor: const Color(0xFF1A4DFF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Teacher", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A4DFF),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Manage Teachers",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A4DFF), Color(0xFF0031D1)],
                ),
              ),
            ),
            // Subtle decorative elements
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: searchController,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: "Search by name or subject...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.blueGrey.shade300,
              size: 22,
            ),
            border: InputBorder.none,
            isDense: true,
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () => searchController.clear(),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map t) {
    String emoji = "�"; // Professional profile symbol
    final sub = (t["subject"] ?? "").toString().toLowerCase();
    if (sub.contains("math"))
      emoji = "📐";
    else if (sub.contains("science") ||
        sub.contains("physics") ||
        sub.contains("chem"))
      emoji = "🔬";
    else if (sub.contains("computer") ||
        sub.contains("python") ||
        sub.contains("it"))
      emoji = "�️";
    else if (sub.contains("english") ||
        sub.contains("hindi") ||
        sub.contains("lang"))
      emoji = "�";
    else if (sub.contains("art") ||
        sub.contains("dance") ||
        sub.contains("music"))
      emoji = "�";
    else if (sub.contains("sport") ||
        sub.contains("pt") ||
        sub.contains("yoga"))
      emoji = "�";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditTeacherDialog(t),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Styled Avatar with Emoji
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4DFF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              // Main Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t["name"],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E263E),
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A4DFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            t["subject"]?.toString().toUpperCase() ?? "GENERAL",
                            style: const TextStyle(
                              color: Color(0xFF1A4DFF),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t["email"],
                            style: TextStyle(
                              color: Colors.blueGrey.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFBDC2D1)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTeacherDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final subjectController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
<<<<<<< HEAD
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
=======
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Register Teacher",
            style: TextStyle(color: primaryColor),
          ),
          content: SingleChildScrollView(
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                const Text(
                  "👨‍🏫 New Teacher",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
=======
                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                  passwordController,
                  "Password",
                  Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(subjectController, "Subject", Icons.book),
                const SizedBox(height: 10),
                _buildTextField(
                  phoneController,
                  "Phone (Optional)",
                  Icons.phone,
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  nameController,
                  "Full Name",
                  Icons.person_outline_rounded,
                ),
                _buildTextField(
                  emailController,
                  "Email Address",
                  Icons.alternate_email_rounded,
                ),
                _buildTextField(
                  passwordController,
                  "Secure Password",
                  Icons.lock_open_rounded,
                  obscure: true,
                ),
                _buildTextField(
                  subjectController,
                  "Specialization Subject",
                  Icons.auto_stories_rounded,
                ),
                _buildTextField(
                  phoneController,
                  "Contact Number",
                  Icons.phone_android_rounded,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4DFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await _api.post("/api/v1/admin/register", {
                          "role": "teacher",
                          "name": nameController.text,
                          "email": emailController.text,
                          "password": passwordController.text,
                          "subject": subjectController.text,
                          "phone": phoneController.text,
                        });
                        Navigator.pop(context);
                        fetchTeachers();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    child: const Text(
                      "Register Specialist",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
<<<<<<< HEAD
=======
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  final res = await _api.post("/api/v1/admin/register", {
                    "role": "teacher",
                    "name": nameController.text,
                    "email": emailController.text,
                    "password": passwordController.text,
                    "subject": subjectController.text,
                    "phone": phoneController.text,
                  });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Teacher registered!")),
                      );
                      fetchTeachers();
                    }
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        );
      },
    );
  }

  void _showEditTeacherDialog(Map t) {
    final nameController = TextEditingController(text: t["name"]);
    final emailController = TextEditingController(text: t["email"]);
    final passwordController = TextEditingController();
    final subjectController = TextEditingController(text: t["subject"]);
    final phoneController = TextEditingController(text: t["phone"]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
<<<<<<< HEAD
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
=======
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Edit Teacher", style: TextStyle(color: primaryColor)),
          content: SingleChildScrollView(
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                const Text(
                  "📝 Edit Specialist",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  nameController,
                  "Full Name",
                  Icons.person_outline_rounded,
                ),
                _buildTextField(
                  emailController,
                  "Email Address",
                  Icons.alternate_email_rounded,
                ),
                _buildTextField(
                  passwordController,
                  "New Password (Optional)",
                  Icons.lock_open_rounded,
                  obscure: true,
                ),
                _buildTextField(
                  subjectController,
                  "Specialization Subject",
                  Icons.auto_stories_rounded,
                ),
                _buildTextField(
                  phoneController,
                  "Contact Number",
                  Icons.phone_android_rounded,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await _api.put("/api/v1/admin/users/${t["user_id"]}", {
                          "role": "teacher",
                          "name": nameController.text,
                          "email": emailController.text,
                          "password": passwordController.text,
                          "subject": subjectController.text,
                          "phone": phoneController.text,
                        });
                        Navigator.pop(context);
                        fetchTeachers();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
=======
                _buildTextField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email", Icons.email),
                const SizedBox(height: 10),
                _buildTextField(
                  passwordController,
                  "New Password",
                  Icons.lock,
                  isObscure: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(subjectController, "Subject", Icons.book),
                const SizedBox(height: 10),
                _buildTextField(phoneController, "Phone", Icons.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  final res = await _api
                      .put("/api/v1/admin/users/${t["user_id"]}", {
                        "role": "teacher",
                        "name": nameController.text,
                        "email": emailController.text,
                        "password": passwordController.text,
                        "subject": subjectController.text,
                        "phone": phoneController.text,
                      });
                  if (res["success"]) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Teacher updated!")),
                      );
                      fetchTeachers();
                    }
                  }
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
<<<<<<< HEAD
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.blueGrey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1A4DFF)),
          filled: true,
          fillColor: const Color(0xFFF4F6FB),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.blueGrey.shade50),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A4DFF), width: 1.5),
          ),
=======
    bool isObscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Future<void> _confirmDelete(Map t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Teacher"),
        content: Text("Are you sure you want to delete ${t['name']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.delete("/api/v1/admin/users/${t['user_id']}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Teacher deleted successfully")),
          );
          fetchTeachers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error deleting teacher: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: primaryColor, // Solid color
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Manage Teachers",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: searchController,
                      cursorColor: primaryColor,
                      decoration: InputDecoration(
                        hintText: "Search Teachers...",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : filteredTeachers.isEmpty
                    ? const Center(
                        child: Text(
                          "No teachers found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTeachers.length,
                        itemBuilder: (context, index) {
                          final t = filteredTeachers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t["name"] ?? "Unnamed",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.book,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              t["subject"] ?? "No Subject",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.phone,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              t["phone"] ?? "No Phone",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: primaryColor,
                                    ),
                                    onPressed: () => _showEditTeacherDialog(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(t),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTeacherDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Teacher", style: TextStyle(color: Colors.white)),
      ),
    );
  }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
}
