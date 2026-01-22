const pool = require("./src/config/db");

async function check() {
    try {
        console.log("Checking DB Connection...");
        const [rows] = await pool.query("SELECT 1+1 as result");
        console.log("Connection OK, result:", rows[0].result);

        const [tables] = await pool.query("SHOW TABLES");
        const tableNames = tables.map(t => Object.values(t)[0]);
        console.log("Tables found:", tableNames);

        for (const table of tableNames) {
            if (['students', 'homework', 'announcements', 'homework_submissions'].includes(table)) {
                const [cols] = await pool.query(`DESCRIBE ${table}`);
                console.log(`Columns in ${table}:`, cols.map(c => c.Field));
            }
        }

        await pool.end();
        console.log("Check completed successfully.");
    } catch (err) {
        console.error("DB Check Failed:", err.message);
    }
}

check();
