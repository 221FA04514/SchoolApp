const pool = require('./src/config/db');
async function test() {
    try {
        console.log("Attempting to connect to database...");
        const [rows] = await pool.query("SELECT 1 as result");
        console.log("Connection successful! Result:", rows);
        process.exit(0);
    } catch (err) {
        console.error("DATABASE CONNECTION FAILED!");
        console.error("Error Message:", err.message);
        console.error("Code:", err.code);
        process.exit(1);
    }
}
test();
