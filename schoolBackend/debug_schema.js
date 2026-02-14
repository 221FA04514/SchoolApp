const fs = require('fs');
const pool = require("./src/config/db");

async function debug() {
    const logFile = "debug_schema_output.txt";
    const log = (msg) => fs.appendFileSync(logFile, msg + "\n");

    try {
        fs.writeFileSync(logFile, "=== DEBUGGING SCHEMA ===\n");

        const [rows] = await pool.query("SHOW CREATE TABLE leaves");
        log(rows[0]["Create Table"]);

    } catch (err) {
        log("Debug Error: " + err);
    } finally {
        process.exit();
    }
}

debug();
