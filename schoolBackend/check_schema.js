require("dotenv").config();
const pool = require("./src/config/db");

async function checkSchema() {
    try {
        const [rows] = await pool.query("DESCRIBE users");
        console.log("--- Schema for 'users' table ---");
        rows.forEach(row => {
            console.log(`${row.Field}: ${row.Type} (Null: ${row.Null}, Key: ${row.Key}, Default: ${row.Default})`);
        });
    } catch (err) {
        console.error("❌ ERROR checking schema:", err.message);
    } finally {
        process.exit();
    }
}

checkSchema();
