const pool = require("./src/config/db");

async function runMigration() {
    try {
        console.log("Starting Teacher Portal migrations...");

        // 1. Update Attendance Status enum and add audit table
        await pool.query(`
      ALTER TABLE attendance 
      MODIFY COLUMN status ENUM('present', 'absent', 'late', 'holiday') DEFAULT 'present'
    `);
        console.log("- Updated attendance status enum");

        await pool.query(`
      CREATE TABLE IF NOT EXISTS attendance_audit (
        id INT AUTO_INCREMENT PRIMARY KEY,
        attendance_id INT NOT NULL,
        old_status ENUM('present', 'absent', 'late', 'holiday'),
        new_status ENUM('present', 'absent', 'late', 'holiday'),
        changed_by INT NOT NULL,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (attendance_id) REFERENCES attendance(id) ON DELETE CASCADE
      )
    `);
        console.log("- Created attendance_audit table");

        // 2. Update Homework table and add submissions
        await pool.query(`
      ALTER TABLE homework
      ADD COLUMN IF NOT EXISTS difficulty_level ENUM('easy', 'medium', 'hard') DEFAULT 'medium',
      ADD COLUMN IF NOT EXISTS content_type VARCHAR(50) DEFAULT 'text'
    `);
        console.log("- Updated homework table");

        await pool.query(`
      CREATE TABLE IF NOT EXISTS homework_submissions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        homework_id INT NOT NULL,
        student_id INT NOT NULL,
        content TEXT,
        file_url VARCHAR(255),
        marks DECIMAL(5,2),
        feedback TEXT,
        status ENUM('pending', 'graded') DEFAULT 'pending',
        submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (homework_id) REFERENCES homework(id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
      )
    `);
        console.log("- Created homework_submissions table");

        // 3. Update Exams and Marks tables
        await pool.query(`
      ALTER TABLE exams
      ADD COLUMN IF NOT EXISTS total_marks INT DEFAULT 100,
      ADD COLUMN IF NOT EXISTS passing_marks INT DEFAULT 35
    `);
        console.log("- Updated exams table");

        await pool.query(`
      ALTER TABLE marks
      ADD COLUMN IF NOT EXISTS grade VARCHAR(5),
      ADD COLUMN IF NOT EXISTS remarks TEXT
    `);
        console.log("- Updated marks table");

        console.log("Migrations completed successfully!");
        process.exit(0);
    } catch (err) {
        console.error("Migration failed:", err);
        process.exit(1);
    }
}

runMigration();
