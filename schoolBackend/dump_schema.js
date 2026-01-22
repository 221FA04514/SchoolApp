const pool = require("./src/config/db");
const fs = require("fs");

async function check() {
    try {
        const [tables] = await pool.query('SHOW TABLES');
        let output = "TABLES:\n";
        const names = tables.map(t => Object.values(t)[0]);
        output += names.join(", ") + "\n\n";

        for (const n of names) {
            if (['students', 'homework', 'announcements', 'homework_submissions', 'sections'].includes(n)) {
                const [cols] = await pool.query('DESCRIBE ' + n);
                output += `COLUMNS IN ${n}:\n`;
                output += cols.map(c => c.Field).join(", ") + "\n\n";
            }
        }

        fs.writeFileSync("schema_dump.txt", output);
        console.log("Dump written to schema_dump.txt");
        process.exit(0);
    } catch (e) {
        fs.writeFileSync("schema_dump.txt", "ERROR: " + e.message);
        process.exit(1);
    }
}

check();
