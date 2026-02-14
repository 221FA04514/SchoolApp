
const pool = require("./src/config/db");

async function inspect() {
    try {
        const [rows] = await pool.query(`SHOW COLUMNS FROM fee_payments`);
        console.log(rows);
    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}

inspect();
