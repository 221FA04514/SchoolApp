require("dotenv").config();
const pool = require("./src/config/db");

async function updateAdminPhone() {
    try {
        const userId = 8;
        const newPhone = '+918185864150';

        const [result] = await pool.query(
            "UPDATE admins SET phone = ? WHERE user_id = ?",
            [newPhone, userId]
        );

        if (result.affectedRows > 0) {
            console.log(`\nSuccessfully updated phone number for Admin (User ID: ${userId}) to ${newPhone}\n`);
        } else {
            console.log(`\nNo admin record found for User ID: ${userId}\n`);
        }

        process.exit(0);
    } catch (err) {
        console.error("Error updating admin phone:", err.message);
        process.exit(1);
    }
}

updateAdminPhone();
