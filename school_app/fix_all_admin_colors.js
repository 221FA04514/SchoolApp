const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Basic color replacements
    code = code.replace(/0xFF1A4DFF/g, '0xFF673AB7');
    code = code.replace(/0xFF0031D1/g, '0xFF512DA8');
    code = code.replace(/0xFF3A6BFF/g, '0xFF512DA8');

    // Gradient replacements
    code = code.replace(/\[Color\(0xFF1A4DFF\), Color\(0xFF0031D1\)\]/g, '[Color(0xFF673AB7), Color(0xFF512DA8)]');

    // Update SliverAppBar to have the Clipper if it looks like the standard one
    if (code.includes('SliverAppBar') && !code.includes('_HeaderClipper') && code.includes('FlexibleSpaceBar')) {
        // Find background Stack
        const backgroundRegex = /background: Stack\([\s\S]*?children: \[([\s\S]*?)Container\([\s\S]*?decoration: const BoxDecoration\([\s\S]*?gradient: LinearGradient\([\s\S]*?colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\],[\s\S]*?\),[\s\S]*?\),/m;

        if (backgroundRegex.test(code)) {
            code = code.replace(backgroundRegex, (match, p1) => {
                return `background: Stack(
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
            ),`;
            });

            // Increase height if it was 140
            code = code.replace(/expandedHeight: 140,/, 'expandedHeight: 180,');
            code = code.replace(/expandedHeight: 120,/, 'expandedHeight: 180,');

            // Add Clipper at the end
            code += `
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height + 40, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
`;
        }
    }

    fs.writeFileSync(filePath, code);
});
