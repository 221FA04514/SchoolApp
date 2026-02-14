const fs = require('fs');
const pool = require("./src/config/db");

async function debug() {
    const logFile = "debug_output.txt";
    const log = (msg) => fs.appendFileSync(logFile, msg + "\n");

    try {
        fs.writeFileSync(logFile, "=== DEBUGGING NOTIFICATIONS ===\n");

        // 1. Check latest mass_notification
        const [notifs] = await pool.query("SELECT * FROM mass_notifications ORDER BY created_at DESC LIMIT 1");
        if (notifs.length === 0) {
            log("No mass notifications found.");
            return;
        }
        const lastNotif = notifs[0];
        log("Latest Notification: " + JSON.stringify(lastNotif, null, 2));

        // 2. Check receipts for this notification
        const [receipts] = await pool.query("SELECT COUNT(*) as count FROM notification_receipts WHERE notification_id = ?", [lastNotif.id]);
        log(`Receipts count for ID ${lastNotif.id}: ${receipts[0].count}`);

        // 3. Check sample receipt users
        const [sampleReceipts] = await pool.query("SELECT * FROM notification_receipts WHERE notification_id = ? LIMIT 5", [lastNotif.id]);
        log("Sample Receipts: " + JSON.stringify(sampleReceipts, null, 2));

        // 4. Check user roles
        const [users] = await pool.query("SELECT id, role, email FROM users LIMIT 5");
        log("Sample Users: " + JSON.stringify(users, null, 2));

        // 5. Check Announcements created (double-write logic)
        const [announcements] = await pool.query("SELECT * FROM announcements ORDER BY created_at DESC LIMIT 1");
        if (announcements.length > 0) {
            log("Latest Announcement: " + JSON.stringify(announcements[0], null, 2));
        } else {
            log("No announcements found.");
        }

    } catch (err) {
        console.error(err);
        log("Debug Error: " + err);
    } finally {
        process.exit();
    }
}

debug();
