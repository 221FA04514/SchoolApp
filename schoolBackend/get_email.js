
const pool = require('./src/config/db');

async function getEmail() {
    try {
        const [rows] = await pool.query("SELECT email FROM users WHERE id = 3");
        console.log("Email:", rows[0].email);
        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

getEmail();
