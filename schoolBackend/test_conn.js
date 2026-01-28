const pool = require('./src/config/db');
async function test() {
    try {
        const [rows] = await pool.query('SELECT 1 as result');
        console.log('SUCCESS:', rows);
        process.exit(0);
    } catch (err) {
        console.error('FAILURE:', err.message);
        process.exit(1);
    }
}
test();
