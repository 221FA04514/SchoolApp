require("dotenv").config();
const pool = require("./src/config/db");

async function migrate() {
    const connection = await pool.getConnection();
    try {
        console.log("Starting migration: linking students to sections table...");

        // 1. Add section_id column to students table
        console.log("Checking if section_id exists in students table...");
        const [columns] = await connection.query("SHOW COLUMNS FROM students LIKE 'section_id'");
        if (columns.length === 0) {
            console.log("Adding section_id column...");
            await connection.query("ALTER TABLE students ADD COLUMN section_id INT AFTER section");
            await connection.query("ALTER TABLE students ADD CONSTRAINT fk_student_section FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE SET NULL");
        } else {
            console.log("section_id column already exists.");
        }

        // 2. Populate section_id based on class and section strings
        console.log("Populating section_id...");
        const [students] = await connection.query("SELECT user_id, class, section FROM students");
        for (const student of students) {
            const { user_id, class: className, section } = student;
            const [sections] = await connection.query("SELECT id FROM sections WHERE class = ? AND section = ?", [className, section]);
            if (sections.length > 0) {
                await connection.query("UPDATE students SET section_id = ? WHERE user_id = ?", [sections[0].id, user_id]);
                console.log(`Linked student ${user_id} to section ${sections[0].id}`);
            } else {
                console.warn(`No matching section found for student ${user_id} (Class ${className}, Section ${section})`);
            }
        }

        console.log("Migration completed successfully!");
    } catch (err) {
        console.error("❌ Migration failed:", err.message);
    } finally {
        connection.release();
        process.exit();
    }
}

migrate();
