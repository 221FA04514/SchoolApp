const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_sections.dart', 'utf-8');
code = code.replace(/\)\s*\n\s+Positioned\(/g, '),\n            Positioned(');
fs.writeFileSync('lib/screens/admin/manage_sections.dart', code);
console.log('Done sections');
