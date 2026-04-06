const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_students.dart', 'utf-8');

// 1. Color replacements
code = code.replace(/0xFF1A4DFF/g, '0xFF673AB7');
code = code.replace(/0xFF0031D1/g, '0xFF512DA8');

// 2. Add _deleteStudent function before _buildStudentCard
const deleteFunc = `  Future<void> _deleteStudent(Map s) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student?"),
        content: Text("Are you sure you want to remove \${s["name"]}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
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
        await _api.delete("/api/v1/admin/users/\${s["user_id"]}");
        fetchData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
        }
      }
    }
  }

  Widget _buildStudentCard(Map s) {`;

code = code.replace(/  Widget _buildStudentCard\(Map s\) \{/, deleteFunc);

// 3. Replace _buildStudentCard body
const oldCardRegex = /  Widget _buildStudentCard\(Map s\) \{[\s\S]*?Widget _buildInfoRow/;
const newCard = `  Widget _buildStudentCard(Map s) {
    return Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Styled Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.school, color: Color(0xFF673AB7), size: 28),
              ),
            ),
            const SizedBox(width: 16),
            // Main Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s["name"],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.class_outlined,
                    "Class \${s["class"]} \${s["section"]} | Roll No: \${s["roll_number"]}",
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.email_outlined, s["email"]),
                ],
              ),
            ),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF673AB7), size: 22),
                  onPressed: () => _showEditStudentDialog(s),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: () => _deleteStudent(s),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow`;

code = code.replace(oldCardRegex, newCard);

// 4. Update sliver app bar to have curved bottom and deeper height
const sliverRegex = /Widget _buildSliverAppBar\(\) \{[\s\S]*?return SliverAppBar\([\s\S]*?expandedHeight.*?140,[\s\S]*?flexibleSpace: FlexibleSpaceBar\([\s\S]*?background: Stack\([\s\S]*?children: \[[\s\S]*?Container\([\s\S]*?decoration: const BoxDecoration\([\s\S]*?gradient: LinearGradient\([\s\S]*?colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?Positioned\([\s\S]*?child: CircleAvatar\([\s\S]*?backgroundColor: Colors\.white\.withOpacity\(0\.05\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\);[\s\S]*?\}/m;

const newSliver = `Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: const Text(
          "Manage Students",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF673AB7), Color(0xFF512DA8)],
                  ),
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
  }`;

code = code.replace(sliverRegex, newSliver);

// 5. Update _buildField to use the correct focused color
code = code.replace(/color: Colors\.blueGrey\.shade300\),/, 'color: const Color(0xFF673AB7)),');
code = code.replace(/contentPadding: const EdgeInsets\.symmetric\(vertical: 16\),/, 'contentPadding: const EdgeInsets.symmetric(vertical: 16),\n          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF673AB7), width: 1.5)),');

// 6. Add _HeaderClipper at the end if it doesn't exist
if (!code.includes('class _HeaderClipper')) {
    const headerClipper = `
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 40,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
`;
    code += headerClipper;
}

fs.writeFileSync('lib/screens/admin/manage_students.dart', code);
