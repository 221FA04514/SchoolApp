const pool = require("./src/config/db");
const service = require("./src/modules/mass_notifications/mass_notifications.service");

async function test() {
    try {
        console.log("=== TESTING TEACHER NOTIFICATIONS ===");
        const teacherId = 6; // Based on previous debug output

        console.log(`Fetching notifications for User ID: ${teacherId}`);
        const notifs = await service.getNotificationsForUser(teacherId);

        console.log(`Found ${notifs.length} notifications.`);
        if (notifs.length > 0) {
            console.log("Sample:", JSON.stringify(notifs[0], null, 2));
        } else {
            // Check if receipts exist at all for this user
            const [receipts] = await pool.query("SELECT * FROM notification_receipts WHERE user_id = ?", [teacherId]);
            console.log(`Debug: User ${teacherId} has ${receipts.length} total receipts in DB.`);
        }
    } catch (err) {
        console.error(err);
    } finally {
        process.exit();
    }
}

test();
