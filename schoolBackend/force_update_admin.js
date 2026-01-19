require("dotenv").config();
const pool = require("./src/config/db");

async function forceUpdate() {
    try {
        const email = 'admin@test.com';
        const newPhone = '+918185864150';

        console.log(`Searching for admin with email: ${email}`);
        const [users] = await pool.query("SELECT id FROM users WHERE email = ? AND role = 'admin'", [email]);

        if (users.length === 0) {
            console.error("Admin user not found!");
            process.exit(1);
        }

        const userId = users[0].id;
        console.log(`Found Admin ID: ${userId}. Updating phone to: ${newPhone}`);

        const [res] = await pool.query("UPDATE admins SET phone = ? WHERE user_id = ?", [newPhone, userId]);
        console.log("Update Result:", res);

        const [updated] = await pool.query("SELECT phone FROM admins WHERE user_id = ?", [userId]);
        console.log("Verified Phone in DB:", updated[0].phone);

        process.exit(0);
    } catch (err) {
        console.error("Error:", err.message);
        process.exit(1);
    }
}

forceUpdate();
