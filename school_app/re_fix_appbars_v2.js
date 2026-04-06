const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const fixList = [
    { file: 'manage_sections.dart', title: 'Sections Hub 📁' },
    { file: 'manage_period_settings.dart', title: 'Time Management' },
    { file: 'manage_mappings.dart', title: 'Mapping Center' },
    { file: 'manage_substitutions.dart', title: 'Substitution Hub' },
    { file: 'notification_center.dart', title: 'Notify Hub' }
];

fixList.forEach(item => {
    const filePath = path.join(adminDir, item.file);
    if (!fs.existsSync(filePath)) return;

    let code = fs.readFileSync(filePath, 'utf-8');

    // Find _buildSliverAppBar method
    const appbarRegex = /Widget _buildSliverAppBar\(\) \{[\s\S]*?\}\s*(\n\s*Widget)/m;

    const newAppBar = `Widget _buildSliverAppBar() {
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
          "${item.title}",
          style: const TextStyle(
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

  Widget`;

    // Wait, let's fix the missing comma in the literal
    const fixedNewAppBar = newAppBar.replace('),\n            Positioned', '), \n            Positioned');
    // Actually, let's just use the correct string literally
    const finalAppBar = `Widget _buildSliverAppBar() {
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
          "${item.title}",
          style: const TextStyle(
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

  Widget`;

    if (appbarRegex.test(code)) {
        console.log(`Final re-fixing appbar in ${item.file}`);
        code = code.replace(appbarRegex, finalAppBar);
        fs.writeFileSync(filePath, code);
    }
});
