const pool = require('./src/config/db');

async function migrate() {
    try {
        console.log('--- Adding allow_copy column ---');
        // Check if column exists
        const [rows] = await pool.query("SHOW COLUMNS FROM online_exams LIKE 'allow_copy'");
        if (rows.length === 0) {
            await pool.query("ALTER TABLE online_exams ADD COLUMN allow_copy BOOLEAN DEFAULT 0");
            console.log("Column 'allow_copy' added successfully.");
        } else {
            console.log("Column 'allow_copy' already exists.");
        }
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

migrate();
