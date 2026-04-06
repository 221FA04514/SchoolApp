const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Look for the end of the ClipPath block and ensure it has a comma
    // The previous script left them without commas
    const searchPattern = /decoration: const BoxDecoration\(\s+gradient: LinearGradient\(\s+begin: Alignment\.topLeft,\s+end: Alignment\.bottomRight,\s+colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\],\s+\),\s+\),\s+\),\s+\)\s+Positioned\(/m;

    // More flexible:
    const regex = /\n\s+colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\],\s+\),\s+\),\s+\),\s+\)\s+Positioned\(/m;

    if (regex.test(code)) {
        console.log(`Fixing comma in ${file}`);
        code = code.replace(regex, (match) => {
            return match.replace(/\s+Positioned\(/, ',\n            Positioned(');
        });
    } else {
        // Let's try matching the literal blocks I made
        // ClipPath closes with ), and Container with ), and BoxDecoration with ), and LinearGradient with ),
        // So exactly 4 levels of parens.
        const fourLevelsPattern = /            \),\n            \),\n            \),\n            \)\n            Positioned\(/g;
        if (fourLevelsPattern.test(code)) {
            console.log(`Fixing 4level comma in ${file}`);
            code = code.replace(fourLevelsPattern, '            ),\n            ),\n            ),\n            ),\n            Positioned(');
        } else {
            // Let's look at what's actually there
            // In manage_sections.dart, line 97 is ), 98 is ), 99 is Positioned.
            // That's ONLY 2 levels visible at that indentation?
            // Wait, let's look at the view_file again.
            /* 
            96:                 ),
            97:               ),
            98:             ),
            99:             Positioned(
            */
            // Line 96 is indented more. Line 97 is indented as child of Container. Line 98 is indented as child of children list?
            // No, the indents are:
            // BoxDecoration 14 spaces?
            // Container 12 spaces?
            // ClipPath 10 spaces?
            // Stack children 8 spaces?
        }
    }

    // Universal fix: look for Positioned prepended by closing parens WITHOUT a comma
    const universalPattern = /\)\s*\n\s+Positioned\(/g;
    code = code.replace(universalPattern, '),\n            Positioned(');

    fs.writeFileSync(filePath, code);
});
