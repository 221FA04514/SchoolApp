const pool = require('../src/config/db');

async function setupSettings() {
    try {
        console.log("Creating school_settings table...");
        await pool.query(`
            CREATE TABLE IF NOT EXISTS school_settings (
                key VARCHAR(100) PRIMARY KEY,
                value TEXT NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // Insert initial academic year if not present
        await pool.query(`
            INSERT INTO school_settings (key, value)
            VALUES ('current_academic_year', '2024-25')
            ON CONFLICT (key) DO NOTHING
        `);

        console.log("Adding academic_year column to students if not exists...");
        await pool.query(`
            ALTER TABLE students ADD COLUMN IF NOT EXISTS academic_year VARCHAR(20) DEFAULT '2024-25'
        `);

        console.log("Database setup complete.");
        process.exit(0);
    } catch (err) {
        console.error("Database setup failed:", err);
        process.exit(1);
    }
}

setupSettings();
