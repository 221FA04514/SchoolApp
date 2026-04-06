const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_sections.dart', 'utf-8');

const oldStack = /background: Stack\([\s\S]*?Positioned\([\s\S]*?\),[\s\S]*?\),[\s\S]*?\],[\s\S]*?\),/m;

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

code = code.replace(oldStack, newStack);
fs.writeFileSync('lib/screens/admin/manage_sections.dart', code);
console.log('Final sections re-write');
