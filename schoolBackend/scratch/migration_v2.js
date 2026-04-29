const pool = require('../src/config/db');

async function migrate() {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        console.log("--- Starting Database Migration ---");

        // 1. Create fees_structure table
        console.log("Step 1: Creating fees_structure table...");
        await connection.query(`
            CREATE TABLE IF NOT EXISTS fees_structure (
                id SERIAL PRIMARY KEY,
                section_id INTEGER NOT NULL UNIQUE REFERENCES sections(id) ON DELETE CASCADE,
                amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
                description VARCHAR(255),
                academic_year VARCHAR(20),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);

        // 2. Fix unpadded time strings in period_settings
        console.log("Step 2: Normalizing times in period_settings...");
        const [settings] = await connection.query("SELECT id, start_time, end_time FROM period_settings");
        for (const s of settings) {
            const pad = (time) => {
                if (!time) return time;
                const parts = time.split(':');
                if (parts.length < 2) return time;
                return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
            };
            const newStart = pad(s.start_time);
            const newEnd = pad(s.end_time);
            if (newStart !== s.start_time || newEnd !== s.end_time) {
                await connection.query("UPDATE period_settings SET start_time = ?, end_time = ? WHERE id = ?", [newStart, newEnd, s.id]);
            }
        }

        // 3. Ensure 'fees' table has description column
        console.log("Step 3: Checking 'fees' table 'description' column...");
        const [feeCols] = await connection.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'fees' AND column_name = 'description'");
        if (feeCols.length === 0) {
            await connection.query("ALTER TABLE fees ADD COLUMN description VARCHAR(255)");
        }

        await connection.commit();
        console.log("--- Migration Completed Successfully ---");
        process.exit(0);
    } catch (err) {
        await connection.rollback();
        console.error("Migration Failed:", err.message);
        process.exit(1);
    } finally {
        connection.release();
    }
}

migrate();
