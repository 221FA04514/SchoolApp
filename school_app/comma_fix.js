const fs = require('fs');
const path = require('path');
const adminDir = 'lib/screens/admin';
const fixList = [
    'manage_sections.dart',
    'manage_period_settings.dart',
    'manage_mappings.dart',
    'manage_substitutions.dart',
    'notification_center.dart'
];

fixList.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Specifically finding the boundary where we know the comma is missing
    code = code.replace(/\)\n            Positioned\(/g, '),\n            Positioned(');

    fs.writeFileSync(filePath, code);
    console.log(`Final comma check for ${file}`);
});
