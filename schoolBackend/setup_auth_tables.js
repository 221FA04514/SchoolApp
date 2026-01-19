require("dotenv").config();
const pool = require("./src/config/db");

async function setupAuthTables() {
    try {
        // 1. Create admins table
        await pool.query(`
      CREATE TABLE IF NOT EXISTS admins (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(15) NOT NULL,
        UNIQUE KEY user_id (user_id),
        CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);
        console.log("Table 'admins' created.");

        // 2. Create otp_codes table
        await pool.query(`
      CREATE TABLE IF NOT EXISTS otp_codes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        code VARCHAR(6) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        KEY fk_otp_user (user_id),
        CONSTRAINT fk_otp_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      ) ENGINE=InnoDB;
    `);
        console.log("Table 'otp_codes' created.");

        // 3. Link existing admin to admins table if not already linked
        const [adminUser] = await pool.query("SELECT id FROM users WHERE role = 'admin' LIMIT 1");
        if (adminUser.length > 0) {
            const userId = adminUser[0].id;
            const [exists] = await pool.query("SELECT id FROM admins WHERE user_id = ?", [userId]);
            if (exists.length === 0) {
                await pool.query("INSERT INTO admins (user_id, name, phone) VALUES (?, ?, ?)", [userId, 'Super Admin', '1234567890']);
                console.log("Existing admin linked to 'admins' table.");
            }
        }

    } catch (err) {
        console.error("Error setting up auth tables:", err.message);
    } finally {
        process.exit();
    }
}

setupAuthTables();
