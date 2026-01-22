const pool = require("./src/config/db");

async function createAiHistoryTable() {
    try {
        console.log("Creating ai_history table...");
        await pool.query(`
            CREATE TABLE IF NOT EXISTS ai_history (
                id INT AUTO_INCREMENT PRIMARY KEY,
                student_id INT NOT NULL,
                type ENUM('homework', 'doubt') NOT NULL,
                prompt TEXT NOT NULL,
                response TEXT NOT NULL,
                image_path TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
        `);
        console.log("ai_history table created successfully.");

        // Check if ai_doubt_history exists and migrate if needed, or just keep it separate.
        // For simplicity and "real-time history", it's better to have a unified table or a view.
        // We'll use the unified table for the new features.

        process.exit(0);
    } catch (err) {
        console.error("Error creating tables:", err);
        process.exit(1);
    }
}

createAiHistoryTable();
