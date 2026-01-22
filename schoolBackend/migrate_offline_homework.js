const pool = require("./src/config/db");

async function run() {
    try {
        console.log("Adding is_offline column to homework table...");
        await pool.query(`
      ALTER TABLE homework 
      ADD COLUMN IF NOT EXISTS is_offline BOOLEAN DEFAULT FALSE
    `);
        console.log("Migration successful!");
        process.exit(0);
    } catch (err) {
        console.error("Migration failed:", err.message);
        process.exit(1);
    }
}

run();
