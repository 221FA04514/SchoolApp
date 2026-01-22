const pool = require("./src/config/db");

async function fix() {
    try {
        console.log("Starting DB Fix...");

        // 1. Ensure homework_submissions exists
        await pool.query(`
            CREATE TABLE IF NOT EXISTS homework_submissions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                homework_id INT NOT NULL,
                student_id INT NOT NULL,
                content TEXT,
                file_url VARCHAR(255),
                marks DECIMAL(5,2),
                feedback TEXT,
                status ENUM('pending', 'submitted', 'graded') DEFAULT 'submitted',
                submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (homework_id) REFERENCES homework(id) ON DELETE CASCADE,
                FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
            )
        `);
        console.log("✅ homework_submissions table ensured.");

        // 2. Add roll_no to students if missing
        const [studentCols] = await pool.query("SHOW COLUMNS FROM students");
        const hasRollNo = studentCols.some(c => c.Field === 'roll_no');
        if (!hasRollNo) {
            await pool.query("ALTER TABLE students ADD COLUMN roll_no VARCHAR(50) DEFAULT NULL");
            console.log("✅ roll_no column added to students.");
        } else {
            console.log("ℹ️ roll_no already exists in students.");
        }

        // 3. Update status enum in attendance
        await pool.query(`
            ALTER TABLE attendance 
            MODIFY COLUMN status ENUM('present', 'absent', 'late', 'holiday') DEFAULT 'present'
        `);
        console.log("✅ attendance status enum updated.");

        console.log("DB Fix Completed Successfully.");
        process.exit(0);
    } catch (err) {
        console.error("❌ DB Fix Failed:", err.message);
        process.exit(1);
    }
}

fix();
