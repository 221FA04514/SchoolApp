const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Fix the stray closing parenthesis issue
    // We look for the specific pattern created by the faulty script
    const strayPattern = /            \),\n            \),\n            Positioned\(/g;
    const fixedPattern = '            ),\n            Positioned(';

    if (strayPattern.test(code)) {
        console.log(`Fixing stray paren in ${file}`);
        code = code.replace(strayPattern, fixedPattern);
        fs.writeFileSync(filePath, code);
    }
});
