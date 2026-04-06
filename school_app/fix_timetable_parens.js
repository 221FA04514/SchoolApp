const fs = require('fs');
let code = fs.readFileSync('lib/screens/admin/manage_timetable.dart', 'utf-8');
// Target the specific missing paren block
code = code.replace(/colors: \[Color\(0xFF673AB7\), Color\(0xFF512DA8\)\]\s*\n\s+\),\s*\n\s+\),\s*\n\s+\),/g, match => {
    return match + '\n            ),';
});
fs.writeFileSync('lib/screens/admin/manage_timetable.dart', code);
