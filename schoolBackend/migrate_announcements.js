const pool = require("./src/config/db");

async function migrateAnnouncements() {
    try {
        console.log("Migrating announcements table...");

        // Add section_id
        await pool.query(`
            ALTER TABLE announcements 
            ADD COLUMN IF NOT EXISTS section_id INT DEFAULT NULL,
            ADD COLUMN IF NOT EXISTS scheduled_at TIMESTAMP NULL DEFAULT NULL,
            ADD COLUMN IF NOT EXISTS attachment_url VARCHAR(255) DEFAULT NULL;
        `);

        console.log("✅ Announcements table updated successfully.");
        process.exit(0);
    } catch (err) {
        console.error("❌ Migration failed:", err.message);
        process.exit(1);
    }
}
migrateAnnouncements();
