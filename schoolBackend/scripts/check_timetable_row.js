const pool = require('../src/config/db');

async function check() {
    try {
        const [rows] = await pool.query("SELECT * FROM timetable LIMIT 1");
        console.log("Sample Row:", rows[0]);
        process.exit(0);
    } catch (err) {
        console.error("Check failed:", err);
        process.exit(1);
    }
}

check();
