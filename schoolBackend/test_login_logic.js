require("dotenv").config();
const pool = require("./src/config/db");
const bcrypt = require("bcrypt");

async function testLogin() {
    const email = 'admin@test.com';
    const password = 'admin123';

    console.log("--- Testing Login Logic ---");
    console.log(`Email to test: ${email}`);

    try {
        const [rows] = await pool.query("SELECT * FROM users WHERE email = ? AND status = 1", [email]);

        if (rows.length === 0) {
            console.log("❌ FAIL: User not found in database with status=1.");
            process.exit();
        }

        const user = rows[0];
        console.log("✅ User found in DB.");
        console.log(`Actual Role: ${user.role}`);
        console.log(`Stored Hash: ${user.password}`);

        const isMatch = await bcrypt.compare(password, user.password);
        if (isMatch) {
            console.log("✅ SUCCESS: Password matches!");
        } else {
            console.log("❌ FAIL: Password mismatch.");
        }

    } catch (err) {
        console.error("❌ ERROR:", err.message);
    } finally {
        process.exit();
    }
}

testLogin();
