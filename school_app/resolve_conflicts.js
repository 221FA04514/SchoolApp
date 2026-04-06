const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Resolve git conflicts by keeping the HEAD version and removing markers
    const conflictRegex = /<<<<<<< HEAD\r?\n([\s\S]*?)=======\r?\n[\s\S]*?>>>>>>>.*?\r?\n/g;

    if (conflictRegex.test(code)) {
        console.log(`Resolving conflicts in ${file}`);
        code = code.replace(conflictRegex, '$1');
        fs.writeFileSync(filePath, code);
    }
});
