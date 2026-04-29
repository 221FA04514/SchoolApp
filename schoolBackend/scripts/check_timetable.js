const pool = require('../src/config/db');

async function check() {
    try {
        const [rows] = await pool.query("SELECT DISTINCT day FROM timetable");
        console.log("Days in DB:", rows);
        process.exit(0);
    } catch (err) {
        console.error("Check failed:", err);
        process.exit(1);
    }
}

check();
