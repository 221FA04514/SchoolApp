require("dotenv").config();
const pool = require("./src/config/db");
const bcrypt = require("bcrypt");

async function fixAdmin() {
    try {
        const email = 'admin@test.com';
        const password = 'admin123';
        const hashedPassword = await bcrypt.hash(password, 10);

        // 1. Try to add 'admin' and 'status' column if they don't exist
        console.log("Checking and updating database schema...");
        try {
            await pool.query("ALTER TABLE users MODIFY COLUMN role ENUM('student', 'teacher', 'admin') NOT NULL");
            console.log("✅ Role enum updated to include 'admin'.");
        } catch (e) {
            console.log("Note: role enum might already be updated or needs manual fix.");
        }

        try {
            // Ensure status column exists (though it usually does)
            await pool.query("ALTER TABLE users ADD COLUMN IF NOT EXISTS status TINYINT(1) DEFAULT 1");
        } catch (e) { }

        // 2. Delete existing admin to be clean
        await pool.query("DELETE FROM users WHERE email = ?", [email]);

        // 3. Insert fresh admin with correct status and role
        await pool.query(
            "INSERT INTO users (email, password, role, status) VALUES (?, ?, ?, ?)",
            [email, hashedPassword, 'admin', 1]
        );

        console.log("--------------------------------------------------");
        console.log("✅ SUCCESS: Admin user 'admin@test.com' fixed!");
        console.log("Credentials:");
        console.log("- Email: admin@test.com");
        console.log("- Password: admin123");
        console.log("--------------------------------------------------");

    } catch (err) {
        console.error("❌ ERROR fixing admin:", err.message);
    } finally {
        process.exit();
    }
}

fixAdmin();
