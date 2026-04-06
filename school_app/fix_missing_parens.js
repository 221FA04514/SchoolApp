const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Check if ClipPath is followed by Container and missing one-more closing paren
    // The pattern we want:
    /*
            ClipPath(
              clipper: _HeaderClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    ...
                  ),
                ),
              ), // <--- This one might be missing!
            ),
    */

    // Let's find ClipPath -> Container -> BoxDecoration -> LinearGradient
    // and see if we have 4 closing parens/braces

    const pattern = /ClipPath\(\s+clipper: _HeaderClipper\(\),\s+child: Container\(\s+decoration: const BoxDecoration\(\s+gradient: LinearGradient\([\s\S]*?\)\s*\)\s*\)\s*Positioned\(/g;

    if (pattern.test(code)) {
        console.log(`Fixing missing closing paren in ${file}`);
        code = code.replace(pattern, (match) => {
            // Re-construct the end part of the ClipPath block
            // It should end with three ) before Positioned
            if (match.includes('),') && match.split(')').length >= 4) return match; // looks ok

            // Let's be more precise
            return match.replace(/Positioned\(/, '),\n            Positioned(');
        });
        fs.writeFileSync(filePath, code);
    }
});
