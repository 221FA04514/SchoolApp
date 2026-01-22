const pool = require('./src/config/db');

async function update() {
    try {
        console.log("Adding Quizzes master table...");
        await pool.query(`
            CREATE TABLE IF NOT EXISTS quizzes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                section_id INT,
                subject VARCHAR(100) NOT NULL,
                title VARCHAR(255) NOT NULL,
                questions JSON NOT NULL,
                total_marks INT DEFAULT 100,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ Quizzes table added.");
    } catch (err) {
        console.error("❌ ERROR adding quizzes table:", err.message);
    }
    process.exit(0);
}
update();
