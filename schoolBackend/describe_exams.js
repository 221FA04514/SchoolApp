require('dotenv').config();
const pool = require('./src/config/db');

async function describe() {
    try {
        const [rows] = await pool.query('DESCRIBE online_exams');
        console.table(rows);
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

describe();
