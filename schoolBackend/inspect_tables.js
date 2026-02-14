const pool = require("./src/config/db");

async function inspect() {
    try {
        const tables = ['timetable', 'sections', 'teachers', 'teacher_absences'];
        const results = {};
        for (const table of tables) {
            const [rows] = await pool.query(`SHOW COLUMNS FROM ${table}`);
            results[table] = rows.map(r => r.Field);
        }
        console.log(JSON.stringify(results, null, 2));
    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}

inspect();
