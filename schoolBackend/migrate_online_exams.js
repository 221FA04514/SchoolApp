const pool = require("./src/config/db");

async function run() {
    const connection = await pool.getConnection();
    try {
        console.log("Creating Online Exam system tables...");
        await connection.beginTransaction();

        // 1. Online Exams Table
        await connection.query(`
      CREATE TABLE IF NOT EXISTS online_exams (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        subject VARCHAR(100) NOT NULL,
        section_id INT NOT NULL,
        start_time DATETIME NOT NULL,
        end_time DATETIME NOT NULL,
        duration_mins INT NOT NULL,
        total_marks INT NOT NULL,
        created_by INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (section_id) REFERENCES sections(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    `);

        // 2. Questions Table
        await connection.query(`
      CREATE TABLE IF NOT EXISTS online_exam_questions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        exam_id INT NOT NULL,
        question_text TEXT NOT NULL,
        answer_text TEXT,
        options_json JSON, -- For MCQs
        marks INT DEFAULT 1,
        FOREIGN KEY (exam_id) REFERENCES online_exams(id) ON DELETE CASCADE
      )
    `);

        // 3. Attempts Table
        await connection.query(`
      CREATE TABLE IF NOT EXISTS online_exam_attempts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        exam_id INT NOT NULL,
        student_id INT NOT NULL,
        start_time DATETIME DEFAULT CURRENT_TIMESTAMP,
        submit_time DATETIME,
        marks_obtained DECIMAL(5,2),
        status ENUM('started', 'submitted', 'locked') DEFAULT 'started',
        FOREIGN KEY (exam_id) REFERENCES online_exams(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        UNIQUE KEY unique_attempt (exam_id, student_id) -- Lock to once
      )
    `);

        // 4. Answers Table (to store student choices)
        await connection.query(`
      CREATE TABLE IF NOT EXISTS online_exam_answers (
        id INT AUTO_INCREMENT PRIMARY KEY,
        attempt_id INT NOT NULL,
        question_id INT NOT NULL,
        student_answer TEXT,
        is_correct BOOLEAN,
        marks_awarded DECIMAL(5,2),
        FOREIGN KEY (attempt_id) REFERENCES online_exam_attempts(id) ON DELETE CASCADE,
        FOREIGN KEY (question_id) REFERENCES online_exam_questions(id) ON DELETE CASCADE
      )
    `);

        await connection.commit();
        console.log("Migration successful!");
        process.exit(0);
    } catch (err) {
        await connection.rollback();
        console.error("Migration failed:", err.message);
        process.exit(1);
    } finally {
        connection.release();
    }
}

run();
