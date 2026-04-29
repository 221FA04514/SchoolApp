const pool = require("../../config/db");

exports.getAllStructures = async () => {
    const [rows] = await pool.query(`
        SELECT fs.*, s.name as section_name
        FROM fees_structure fs
        JOIN sections s ON fs.section_id = s.id
        ORDER BY s.name ASC
    `);
    return rows;
};

exports.upsertStructure = async ({ section_id, amount, description, academic_year }) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Upsert into fees_structure
        await connection.query(`
            INSERT INTO fees_structure (section_id, amount, description, academic_year)
            VALUES (?, ?, ?, ?)
            ON CONFLICT (section_id) DO UPDATE
            SET
                amount = EXCLUDED.amount,
                description = EXCLUDED.description,
                academic_year = EXCLUDED.academic_year
        `, [section_id, amount, description, academic_year]);

        // 2. Propagate to all students in this section who DON'T have a custom fee or update everyone
        // For simplicity: Update ALL students in this section to this amount in the 'fees' table
        // This sets the base fee for the whole section.
        const [students] = await connection.query("SELECT user_id FROM students WHERE section_id = ?", [section_id]);
        
        for (const student of students) {
            await connection.query(`
                INSERT INTO fees (student_id, total_amount, description)
                VALUES (?, ?, ?)
                ON CONFLICT (student_id) DO UPDATE
                SET
                    total_amount = EXCLUDED.total_amount,
                    description = EXCLUDED.description
            `, [student.user_id, amount, description]);
        }

        await connection.commit();
        return true;
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};

exports.updateIndividualFee = async (studentUserId, amount, description) => {
    await pool.query(`
        INSERT INTO fees (student_id, total_amount, description)
        VALUES (?, ?, ?)
        ON CONFLICT (student_id) DO UPDATE
        SET
            total_amount = EXCLUDED.total_amount,
            description = EXCLUDED.description
    `, [studentUserId, amount, description]);
};
