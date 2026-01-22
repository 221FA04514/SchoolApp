const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log("Connected to database for migration...");

    const tables = [
        `CREATE TABLE IF NOT EXISTS ai_doubt_history (
            id INT AUTO_INCREMENT PRIMARY KEY,
            student_id INT NOT NULL,
            prompt TEXT NOT NULL,
            response TEXT NOT NULL,
            subject VARCHAR(100),
            resolved_by_ai BOOLEAN DEFAULT TRUE,
            teacher_id_esc INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (teacher_id_esc) REFERENCES users(id) ON DELETE SET NULL
        )`,
        `CREATE TABLE IF NOT EXISTS study_plans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            student_id INT NOT NULL,
            week_start_date DATE NOT NULL,
            plan_json JSON NOT NULL,
            progress_pct INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
        )`,
        `CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            body TEXT NOT NULL,
            type ENUM('homework', 'attendance', 'announcement', 'general') DEFAULT 'general',
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`
    ];

    for (const sql of tables) {
        try {
            await connection.query(sql);
            console.log("Successfully created table or it already exists.");
        } catch (err) {
            console.error("Migration error:", err.message);
        }
    }

    await connection.end();
    process.exit(0);
}

migrate();
