require("dotenv").config();
const pool = require("./src/config/db");
const fs = require("fs");

async function checkSectionsSchema() {
    try {
        const [rows] = await pool.query("DESCRIBE sections");
        let output = "--- Schema for 'sections' table ---\n";
        rows.forEach(row => {
            output += `${row.Field}: ${row.Type} (Null: ${row.Null}, Key: ${row.Key}, Default: ${row.Default})\n`;
        });
        fs.writeFileSync("sections_schema.txt", output);
        console.log("Schema written to sections_schema.txt");
    } catch (err) {
        fs.writeFileSync("sections_schema.txt", "❌ ERROR checking schema: " + err.message);
    } finally {
        process.exit();
    }
}

checkSectionsSchema();
