require("dotenv").config();
const pool = require("./src/config/db");

async function checkAdmins() {
    try {
        const [rows] = await pool.query(`
      SELECT u.id, u.email, a.phone 
      FROM users u 
      JOIN admins a ON u.id = a.user_id 
      WHERE u.role = 'admin'
    `);

        console.log("\n--- ADMIN USERS IN DATABASE ---");
        if (rows.length === 0) {
            console.log("No admins found!");
        } else {
            console.table(rows);
        }
        console.log("-------------------------------\n");

        console.log("TIP: To update a phone number, run:");
        console.log("UPDATE admins SET phone = '+91XXXXXXXXXX' WHERE user_id = USER_ID_HERE;");

        process.exit(0);
    } catch (err) {
        console.error("Error checking admins:", err.message);
        process.exit(1);
    }
}

checkAdmins();
