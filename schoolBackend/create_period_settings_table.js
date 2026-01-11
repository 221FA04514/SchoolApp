require("dotenv").config();
const pool = require("./src/config/db");

async function createTable() {
    try {
        const query = `
      CREATE TABLE IF NOT EXISTS period_settings (
        id INT AUTO_INCREMENT PRIMARY KEY,
        period_number INT UNIQUE NOT NULL,
        start_time VARCHAR(10) NOT NULL,
        end_time VARCHAR(10) NOT NULL
      ) ENGINE=InnoDB;
    `;
        await pool.query(query);
        console.log("Table 'period_settings' created or already exists.");
    } catch (err) {
        console.error("Error creating table:", err.message);
    } finally {
        process.exit();
    }
}

createTable();
