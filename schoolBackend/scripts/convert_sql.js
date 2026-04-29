const fs = require('fs');

const inputFile = 'full_production_db.sql';
const outputFile = 'school_db_postgres.sql';

console.log(`Converting ${inputFile} to ${outputFile}...`);

try {
    // Read with UTF-8 (user created file in editor)
    let content = fs.readFileSync(inputFile, 'utf8');

    // 1. Pre-process global replacements
    content = content.replace(/\/\*!.*?\*\/;/g, '');
    content = content.replace(/SET @[a-z_]+ = .*?;/gi, '');
    content = content.replace(/`/g, '"');
    
    // Replace integer types to be generic (Postgres doesn't support display widths like INT(11))
    content = content.replace(/\btinyint\(1\)\b/gi, 'BOOLEAN');
    content = content.replace(/\btinyint\b/gi, 'SMALLINT');
    content = content.replace(/\bint\(\d+\)/gi, 'INTEGER');
    content = content.replace(/\bint\b/gi, 'INTEGER');
    content = content.replace(/\bsmallint\(\d+\)/gi, 'SMALLINT');
    content = content.replace(/\binteger\(\d+\)/gi, 'INTEGER');
    content = content.replace(/\bdatetime\b/gi, 'TIMESTAMP');

    content = content.replace(/\blongtext\b/gi, 'TEXT');
    content = content.replace(/\bmediumtext\b/gi, 'TEXT');
    
    // Strip MySQL-specific ON UPDATE clauses
    content = content.replace(/ ON UPDATE CURRENT_TIMESTAMP/gi, '');
    content = content.replace(/ ON UPDATE NOW\(\)/gi, '');

    // 2. Process CREATE TABLE blocks
    const tableRegex = /CREATE TABLE "([^"]+)" \(([\s\S]+?)\) ENGINE=.*?;/gi;
    const tableBlocks = [];
    
    // First, extract all table blocks
    let match;
    while ((match = tableRegex.exec(content)) !== null) {
        const tableName = match[1];
        const tableBody = match[2];
        const lines = tableBody.split('\n').map(l => l.trim()).filter(l => l);
        const newLines = [];
        const indices = [];

        lines.forEach(line => {
            let processedLine = line;

            // Handle AUTO_INCREMENT -> SERIAL
            if (processedLine.match(/INTEGER NOT NULL AUTO_INCREMENT/i)) {
                processedLine = processedLine.replace(/"([^"]+)" INTEGER NOT NULL AUTO_INCREMENT/i, '"$1" SERIAL NOT NULL');
            } else if (processedLine.match(/INTEGER AUTO_INCREMENT/i)) {
                processedLine = processedLine.replace(/"([^"]+)" INTEGER AUTO_INCREMENT/i, '"$1" SERIAL');
            }

            // Handle ENUM -> VARCHAR + CHECK
            if (processedLine.match(/ enum\((.*?)\)/i)) {
                processedLine = processedLine.replace(/"([^"]+)" enum\((.*?)\)/i, (m, col, vals) => {
                    return `"${col}" VARCHAR(50) CHECK ("${col}" IN (${vals}))`;
                });
            }

            // Handle UNIQUE KEY -> CONSTRAINT ... UNIQUE
            const uniqueMatch = processedLine.match(/^UNIQUE KEY "([^"]+)" \((.*?)\),?$/i);
            if (uniqueMatch) {
                newLines.push(`CONSTRAINT "${tableName}_${uniqueMatch[1]}" UNIQUE (${uniqueMatch[2]})`);
                return;
            }

            // Handle KEY (Regular index) -> Separate CREATE INDEX
            const keyMatch = processedLine.match(/^KEY "([^"]+)" \((.*?)\),?$/i);
            if (keyMatch && !processedLine.includes('FOREIGN KEY')) {
                indices.push(`CREATE INDEX "${tableName}_${keyMatch[1]}" ON "${tableName}" (${keyMatch[2]});`);
                return;
            }


            newLines.push(processedLine);
        });

        // Reconstruct the table body
        let resultBody = newLines.map((l, i) => {
            let clean = l.replace(/,$/, ''); 
            return i < newLines.length - 1 ? clean + ',' : clean;
        }).join('\n  ');

        const fullBlock = `DROP TABLE IF EXISTS "${tableName}" CASCADE;\nCREATE TABLE "${tableName}" (\n  ${resultBody}\n);\n${indices.join('\n')}\n`;
        tableBlocks.push({ name: tableName, content: fullBlock });
    }

    // Define table creation priority (tables without dependencies first)
    // We sort tables so that parents are created/inserted BEFORE children
    const priority = [
        'users', 
        'sections', 
        'period_settings',
        'mass_notifications',
        'students', 
        'teachers', 
        'admins',
        'exams',
        'homework',
        'attendance',
        'results',
        'teacher_absences',
        'substitutions',
        'teacher_subject_mappings',
        'online_exams',
        'online_exam_questions',
        'online_exam_attempts',
        'online_exam_answers',
        'announcements',
        'leaves',
        'messages',
        'notifications',
        'notification_receipts',
        'homework_submissions',
        'student_homework_status',
        'fees',
        'fee_payments',
        'fee_transaction_logs',
        'timetable'
    ];
    tableBlocks.sort((a, b) => {
        const aIndex = priority.indexOf(a.name);
        const bIndex = priority.indexOf(b.name);
        if (aIndex !== -1 && bIndex !== -1) return aIndex - bIndex;
        if (aIndex !== -1) return -1;
        if (bIndex !== -1) return 1;
        return a.name.localeCompare(b.name); // Deterministic ordering for others
    });

    // 4. Extract and Sort INSERTS
    const insertRegex = /INSERT INTO "([^"]+)" VALUES [\s\S]+?;/gi;
    const insertBlocks = [];
    let insertMatch;
    while ((insertMatch = insertRegex.exec(content)) !== null) {
        insertBlocks.push({ name: insertMatch[1], content: insertMatch[0] });
    }

    // Sort inserts using the same priority
    insertBlocks.sort((a, b) => {
        const aIndex = priority.indexOf(a.name);
        const bIndex = priority.indexOf(b.name);
        if (aIndex !== -1 && bIndex !== -1) return aIndex - bIndex;
        if (aIndex !== -1) return -1;
        if (bIndex !== -1) return 1;
        return 0;
    });

    // 5. Combine: Sorted Tables + Indexes + Sorted Inserts
    let finalContent = tableBlocks.map(b => b.content).join('\n') + '\n\n' + insertBlocks.map(i => i.content).join('\n');

    // 6. Post-process and fix escaped single quotes (MySQL \' -> Postgres '')
    // 7. Add sequence resets for PostgreSQL (to prevent duplicate key errors on new inserts)
    finalContent += '\n\n-- Resetting sequences to match imported data\n';
    tableBlocks.forEach(table => {
        // Only reset tables that we likely have an 'id' column for
        finalContent += `SELECT setval(pg_get_serial_sequence('"${table.name}"', 'id'), coalesce(max(id), 1), max(id) IS NOT NULL) FROM "${table.name}";\n`;
    });

    let sanitizedContent = finalContent.replace(/\\'/g, "''");
    
    sanitizedContent = sanitizedContent.replace(/b'([01])'/g, '$1'); // Fix bit values
    sanitizedContent = sanitizedContent.replace(/\\"/g, '"'); // Fix escaped double quotes in JSON

    // Final write as UTF-8 without any BOMs or stray characters
    fs.writeFileSync(outputFile, sanitizedContent, 'utf8');
    console.log('Conversion complete with Table Reordering and Sequence Resets!');
} catch (err) {
    console.error('Error during conversion:', err.message);
}
