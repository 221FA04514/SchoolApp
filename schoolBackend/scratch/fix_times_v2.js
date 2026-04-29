const pool = require('../src/config/db');

async function fixTimes() {
    try {
        console.log("--- Fixing Timetable and Period Times ---");

        // 1. Fix period_settings
        const [settings] = await pool.query("SELECT id, start_time, end_time FROM period_settings");
        for (const s of settings) {
            const normalize = (val) => {
                if (!val) return val;
                if (val.includes(':') && val.split(':').length >= 2) {
                    const parts = val.split(':');
                    return `${parts[0].padStart(2, '0')}:${parts[1].padStart(2, '0')}`;
                }
                return val;
            };
            const newStart = normalize(s.start_time);
            const newEnd = normalize(s.end_time);
            if (newStart !== s.start_time || newEnd !== s.end_time) {
                await pool.query("UPDATE period_settings SET start_time = ?, end_time = ? WHERE id = ?", [newStart, newEnd, s.id]);
            }
        }

        // 2. Fix active timetable (many have weird 00:00:09)
        // If a value is like 00:00:XX, it's likely a misparsed HH:MM.
        // We'll reset them to match period_settings if they look like trash.
        console.log("Cleaning up active timetable times...");
        // Actually, it's better to just re-link them to period_settings if we can,
        // but timetable stores them as independent strings/times.
        // Let's just wipe times that look like '00:00:XX' if XX > 0.
        await pool.query(`
            UPDATE timetable 
            SET start_time = '08:00:00', end_time = '08:45:00' 
            WHERE start_time < '01:00:00'
        `);

        console.log("--- Cleanup Done ---");
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

fixTimes();
