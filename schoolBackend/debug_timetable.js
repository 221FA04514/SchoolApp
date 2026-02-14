const pool = require("./src/config/db");

async function debug() {
    try {
        const teacherId = 8;
        const period = '2';
        const dateStr = '2026-02-08'; // Sunday

        // 1. Get Teacher Name
        const [tRows] = await pool.query("SELECT name FROM teachers WHERE id = ?", [teacherId]);
        if (tRows.length === 0) {
            console.log("Teacher not found");
            return;
        }
        const teacherName = tRows[0].name;
        console.log(`Teacher: ${teacherName} (ID: ${teacherId})`);

        // 2. Get Day Name
        const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(new Date(dateStr));
        console.log(`Date: ${dateStr} is a ${dayName}`);

        // 3. Query Timetable
        const [rows] = await pool.query(
            "SELECT * FROM timetable WHERE teacher_name = ? AND day = ? AND period = ?",
            [teacherName, dayName, period]
        );

        console.log(`Timetable Entries for ${dayName}, Period ${period}:`);
        if (rows.length === 0) {
            console.log("No class found.");
        } else {
            console.log(rows);
        }

    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}

debug();
