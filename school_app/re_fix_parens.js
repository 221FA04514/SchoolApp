const fs = require('fs');
const path = require('path');

const adminDir = 'lib/screens/admin';
const files = fs.readdirSync(adminDir).filter(f => f.endsWith('.dart'));

files.forEach(file => {
    const filePath = path.join(adminDir, file);
    let code = fs.readFileSync(filePath, 'utf-8');

    // Look for ClipPath followed by Positioned but missing enough closing parens
    // Pattern: 
    //            ),
    //            Positioned(

    // We want the part that matches the end of the ClipPath block
    // Specifically looking for the missing ), before Positioned

    const badPattern = /colors: \[[\s\S]*?\n\s+\),\s+\)\s+,?\s+\)\s+,?\s+Positioned\(/g;
    // Wait, this is too complex.

    // Simpler: 
    // Find Positioned(
    // If the line before is just ), but not two levels of ),
    // Actually, let's just count the parens in the block between ClipPath and Positioned.

    const parts = code.split('ClipPath(');
    if (parts.length > 1) {
        for (let i = 1; i < parts.length; i++) {
            const nextPart = parts[i];
            const positionedIndex = nextPart.indexOf('Positioned(');
            if (positionedIndex > -1) {
                const block = nextPart.substring(0, positionedIndex);
                const openParens = (block.match(/\(/g) || []).length;
                const closeParens = (block.match(/\)/g) || []).length;

                if (openParens > closeParens) {
                    console.log(`Fixing missing paren in ${file} at block ${i}`);
                    // Add missing parens to the end of the block
                    const missing = openParens - closeParens;
                    let fixedBlock = block.trimEnd();
                    for (let j = 0; j < missing; j++) {
                        fixedBlock += '),\n            ';
                    }
                    parts[i] = nextPart.replace(block, fixedBlock);
                    code = parts.join('ClipPath(');
                }
            }
        }
        fs.writeFileSync(filePath, code);
    }
});
