require("dotenv").config();
const pool = require("./src/config/db");
const fs = require("fs");

async function huntString() {
    const target = "7890";
    console.log(`Hunting for "${target}" across all tables...`);

    try {
        const [tables] = await pool.query("SHOW TABLES");
        const results = [];

        for (const tableObj of tables) {
            const tableName = Object.values(tableObj)[0];
            const [columns] = await pool.query(`SHOW COLUMNS FROM ${tableName}`);

            for (const col of columns) {
                if (col.Type.includes("char") || col.Type.includes("text")) {
                    const [matches] = await pool.query(`SELECT * FROM ${tableName} WHERE \`${col.Field}\` LIKE ?`, [`%${target}%`]);
                    if (matches.length > 0) {
                        results.push({ table: tableName, column: col.Field, count: matches.length, samples: matches });
                    }
                }
            }
        }

        fs.writeFileSync("hunt_results.json", JSON.stringify(results, null, 2), "utf8");
        console.log("Hunt complete. Results in hunt_results.json");
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

huntString();
