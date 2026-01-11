require("dotenv").config();
const pool = require("./src/config/db");
const bcrypt = require("bcrypt");

async function checkAdmin() {
    try {
        const email = 'admin@test.com';
        const password = 'admin123';

        const [rows] = await pool.query("SELECT * FROM users WHERE email = ?", [email]);

        if (rows.length === 0) {
            console.log("❌ ERROR: User 'admin@test.com' NOT FOUND in database.");
            process.exit();
        }

        const user = rows[0];
        console.log("✅ User found:", {
            id: user.id,
            email: user.email,
            role: user.role,
            status: user.status,
            type_of_status: typeof user.status
        });

        console.log("Input Password:", password);
        console.log("Database Hash:", user.password);

        const isMatch = await bcrypt.compare(password, user.password);
        if (isMatch) {
            console.log("✅ Password MATCHES!");
        } else {
            console.log("❌ ERROR: Password DOES NOT MATCH the hash in database.");
            console.log("Database Hash:", user.password);
        }

    } catch (err) {
        console.error("❌ DB ERROR:", err.message);
    } finally {
        process.exit();
    }
}

checkAdmin();
