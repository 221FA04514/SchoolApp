const pool = require('./src/config/db');

async function update() {
    console.log("Adding Leaves table...");
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS leaves (
                id INT AUTO_INCREMENT PRIMARY KEY,
                student_id INT NOT NULL,
                reason TEXT NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE NOT NULL,
                status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
                applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Leaves table added.");
    } catch (err) {
        console.error("❌ ERROR adding leaves table:", err.message);
    }
    process.exit(0);
}
update();
