require("dotenv").config();
const pool = require("./src/config/db");
const fs = require("fs");

async function exportAdmins() {
    try {
        const [rows] = await pool.query(`
      SELECT u.id as user_id, u.email, a.id as admin_record_id, a.phone 
      FROM users u 
      LEFT JOIN admins a ON u.id = a.user_id 
      WHERE u.role = 'admin'
    `);

        fs.writeFileSync("admins_state.json", JSON.stringify(rows, null, 2), "utf8");
        console.log("Exported to admins_state.json");
        process.exit(0);
    } catch (err) {
        fs.writeFileSync("error_log.txt", err.message, "utf8");
        console.error(err);
        process.exit(1);
    }
}

exportAdmins();
