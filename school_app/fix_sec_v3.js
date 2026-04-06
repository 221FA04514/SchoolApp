const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_sections.dart', 'utf-8');

// The most reliable way to fix a corrupted block is to replace it by uniquely identifiable landmarks
const startMarker = 'Widget _buildSliverAppBar() {';
const endMarker = 'Widget _buildSectionList() {';

const newContent = `  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF673AB7),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Sections Hub 📁",
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
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

`;

const parts = code.split(startMarker);
const secondPart = parts[1].split(endMarker);

code = parts[0] + startMarker + "\n" + newContent + "\n" + endMarker + secondPart[1];

fs.writeFileSync('lib/screens/admin/manage_sections.dart', code);
console.log('Fixed Sections Hub completely');
