const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = [
    { name: 'manage_sections.dart', title: 'Sections Hub 📁' },
    { name: 'manage_period_settings.dart', title: 'Time Management' },
    { name: 'manage_mappings.dart', title: 'Mapping Center' },
    { name: 'manage_substitutions.dart', title: 'Substitution Hub' },
    { name: 'notification_center.dart', title: 'Notify Hub' }
];

files.forEach(fileData => {
    const filePath = path.join(adminDir, fileData.name);
    if (!fs.existsSync(filePath)) return;

    let code = fs.readFileSync(filePath, 'utf-8');

    // Update colors if not already done (redundant but safe)
    code = code.replace(/0xFF1A4DFF/g, '0xFF673AB7');
    code = code.replace(/0xFF0031D1/g, '0xFF512DA8');

    // Replace SliverAppBar background
    // We look for flexibleSpace: FlexibleSpaceBar(...)
    // and specifically the background: Stack(...)

    const stackPattern = /background: Stack\([\s\S]*?Positioned\([\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/m;

    const newStack = `background: Stack(
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
        ),`;

    if (stackPattern.test(code)) {
        console.log(`Updating header in ${fileData.name}`);
        code = code.replace(stackPattern, newStack);
    } else {
        // Fallback: search for just the background part if Stack is formatted differently
        const bgPattern = /background: [\s\S]*?\n\s+Positioned\([\s\S]*?\),[\s\S]*?\],/m;
        if (bgPattern.test(code)) {
            console.log(`Updating header (fallback) in ${fileData.name}`);
            // This is riskier, let's just use replace_file_content if this fails.
        }
    }

    // Add _HeaderClipper if missing
    if (!code.includes('class _HeaderClipper')) {
        console.log(`Adding _HeaderClipper to ${fileData.name}`);
        code = code.trim();
        // Remove trailing braces if we are going to append correctly
        // Actually, just append it after the last brace
        code += `

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
    }

    fs.writeFileSync(filePath, code);
});
