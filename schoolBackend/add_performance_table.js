const pool = require('./src/config/db');

async function migrate() {
    try {
        console.log('--- Creating student_performances table ---');
        await pool.query(`
            CREATE TABLE IF NOT EXISTS student_performances (
                id INT AUTO_INCREMENT PRIMARY KEY,
                student_id INT NOT NULL,
                teacher_id INT NOT NULL,
                performance_rating ENUM('Good', 'Bad', 'Need to improve') NOT NULL,
                remarks TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE,
                FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `);
        console.log("Table 'student_performances' created successfully.");
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

migrate();
