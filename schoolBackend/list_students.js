
const pool = require('./src/config/db');

async function listStudents() {
    try {
        const [rows] = await pool.query("SELECT id, email, role, password FROM users WHERE role = 'student' LIMIT 1");
        console.log(JSON.stringify(rows, null, 2));
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

listStudents();
