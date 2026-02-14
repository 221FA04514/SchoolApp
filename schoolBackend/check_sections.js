const pool = require("./src/config/db");

async function check() {
    try {
        const [rows] = await pool.query("SELECT id, section FROM sections WHERE id = 1");
        if (rows.length > 0) {
            console.log("Section 1 exists:", rows[0]);
        } else {
            console.log("Section 1 DOES NOT exist.");
        }

        // Also check what sections DO exist
        const [all] = await pool.query("SELECT id, section FROM sections LIMIT 5");
        console.log("Available sections:", all);

    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}

check();
