const pool = require('./src/config/db');

async function upgradeDatabase() {
    console.log("=== STARTING DATABASE UPGRADE V2 (ENTREPRISE STUDENT PORTAL) ===");

    const queries = [
        // 1. Notifications Table
        `CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            body TEXT NOT NULL,
            type ENUM('homework', 'attendance', 'announcement', 'general') DEFAULT 'general',
            is_read BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`,

        // 2. AI Doubt History Table
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

        // 3. Study Plans Table (AI Generated)
        `CREATE TABLE IF NOT EXISTS study_plans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            student_id INT NOT NULL,
            week_start_date DATE NOT NULL,
            plan_json JSON NOT NULL,
            progress_pct INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
        )`,

        // 4. Resources Table (Digital Library)
        `CREATE TABLE IF NOT EXISTS resources (
            id INT AUTO_INCREMENT PRIMARY KEY,
            section_id INT,
            subject VARCHAR(100) NOT NULL,
            title VARCHAR(255) NOT NULL,
            file_url VARCHAR(255) NOT NULL,
            type ENUM('pdf', 'video', 'link') NOT NULL,
            uploaded_by INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
            FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
        )`,

        // 5. Quiz Success Table
        `CREATE TABLE IF NOT EXISTS quiz_attempts (
            id INT AUTO_INCREMENT PRIMARY KEY,
            student_id INT NOT NULL,
            subject VARCHAR(100) NOT NULL,
            topic VARCHAR(255),
            score INT NOT NULL,
            total_questions INT NOT NULL,
            time_taken_sec INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
        )`
    ];

    for (let i = 0; i < queries.length; i++) {
        try {
            console.log(`Executing query ${i + 1}/${queries.length}...`);
            await pool.query(queries[i]);
        } catch (err) {
            console.error(`❌ Error in query ${i + 1}:`, err.message);
        }
    }

    console.log("✅ DATABASE UPGRADE V2 COMPLETE.");
    process.exit(0);
}

upgradeDatabase();
