const pool = require('../src/config/db');

async function migrate() {
    try {
        console.log("Checking for deadline column in announcements...");
        await pool.query(`
            ALTER TABLE announcements 
            ADD COLUMN IF NOT EXISTS deadline TIMESTAMP DEFAULT NULL;
        `);
        console.log("Migration successful!");
        process.exit(0);
    } catch (err) {
        console.error("Migration failed:", err);
        process.exit(1);
    }
}

migrate();
