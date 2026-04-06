const fs = require('fs');
const path = require('path');
const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Fix missing comma between ClipPath block and Positioned block
    // Specifically looking for:
    //             ),
    //             Positioned(
    // where the first line is missing a comma.

    // Pattern: 
    //            ),
    //            Positioned(

    const pattern = /(\s+\),\n\s+Positioned\()/g;

    if (pattern.test(code)) {
        console.log(`Fixing missing comma in ${file}`);
        code = code.replace(pattern, (match) => {
            if (match.includes('),')) return match; // already has comma
            return match.replace('),', '),'); // Wait, replace handle
            // Proper replacement:
            return match.replace(')\n', '),\n');
        });
        fs.writeFileSync(filePath, code);
    }
});
