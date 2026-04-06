const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // 1. Fix missing commas between Stack children
    // If we have ClipPath followed by Positioned without a comma
    const missingCommaPattern = /\)\s+\n\s+Positioned\(/g;
    // Actually, let's be more specific based on seen code
    // ), followed by newline and then Positioned(
    const strayParenPattern = /\)\s*\n\s*\)\s*\n\s*Positioned\(/g;
    const fixedParenPattern = `            ),\n            Positioned(`;

    // Let's just fix it by looking for the ClipPath block ending and Positioned starting
    if (code.includes('ClipPath(') && code.includes('Positioned(')) {
        // Find the boundary
        const boundaryPattern = /\),\s+\),\s*\n\s+Positioned\(/g;
        if (boundaryPattern.test(code)) {
            console.log(`Fixing boundary in ${file}`);
            code = code.replace(boundaryPattern, '),\n            ),\n            Positioned(');
        } else {
            // Maybe it already has one ) but missing a comma?
            // Let's actually use a more robust regex
            // Match the end of the ClipPath block and the start of Positioned
            const robustPattern = /_HeaderClipper\(\),[\s\S]*?colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\],[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\n\s+Positioned/m;

            code = code.replace(robustPattern, (match) => {
                // Ensure we have exactly 4 closing parens for the clipped block, and then a comma!
                // Actually the clipped block has 4 levels: LinearGradient, BoxDecoration, Container, ClipPath.
                // Plus the colors [...] which has 1 level of brackets.
                // So total 4 parens.

                // Let's re-write the block correctly
                return `_HeaderClipper(),
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
            Positioned`;
            });
        }
    }

    fs.writeFileSync(filePath, code);
});
