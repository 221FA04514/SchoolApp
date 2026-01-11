require("dotenv").config();
const pool = require("../src/config/db");

async function createTable() {
    try {
        const query = `
      CREATE TABLE IF NOT EXISTS student_homework_status (
        id INT AUTO_INCREMENT PRIMARY KEY,
        student_id INT NOT NULL,
        homework_id INT NOT NULL,
        is_completed BOOLEAN DEFAULT FALSE,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY unique_status (student_id, homework_id),
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (homework_id) REFERENCES homework(id) ON DELETE CASCADE
      );
    `;

        await pool.query(query);
        console.log("Table 'student_homework_status' created or already exists.");
        process.exit(0);
    } catch (err) {
        console.error("Error creating table:", err);
        process.exit(1);
    }
}

createTable();
