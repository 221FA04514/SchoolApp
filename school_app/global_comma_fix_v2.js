const fs = require('fs');
const path = require('path');
const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Look for ")"; followed by newline and "Positioned("
    // We want to turn it into "), "
    const regex = /\)\n\s+Positioned\(/g;

    if (regex.test(code)) {
        console.log(`Adding missing comma to ${file}`);
        code = code.replace(regex, (match) => {
            return '), \n            Positioned(';
        });
        fs.writeFileSync(filePath, code);
    }
});
