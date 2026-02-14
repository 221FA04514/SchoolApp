const pool = require("./src/config/db");

async function fixRoleColumn() {
    try {
        const connection = await pool.getConnection();
        console.log("Connected to database...");

        console.log("Altering teacher_subject_mappings table...");
        await connection.query("ALTER TABLE teacher_subject_mappings MODIFY COLUMN role VARCHAR(50);");

        console.log("Successfully updated 'role' column to VARCHAR(50).");
        connection.release();
        process.exit(0);
    } catch (error) {
        console.error("Error updating table:", error);
        process.exit(1);
    }
}

fixRoleColumn();
