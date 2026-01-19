require("dotenv").config();
const pool = require("./src/config/db");
const fs = require("fs");

async function findConflict() {
    try {
        const [allAdmins] = await pool.query("SELECT id, email, role, status FROM users WHERE role = 'admin' OR email LIKE '%admin%'");
        const [allAdminRecords] = await pool.query("SELECT * FROM admins");

        const state = {
            allAdmins,
            allAdminRecords
        };

        fs.writeFileSync("conflict_check.json", JSON.stringify(state, null, 2), "utf8");
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

findConflict();
