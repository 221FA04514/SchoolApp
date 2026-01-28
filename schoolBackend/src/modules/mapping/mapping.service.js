const pool = require("../../config/db");

/**
 * Audit log helper
 */
async function logAudit(connection, mappingId, action, performedBy, oldValue, newValue) {
    await connection.query(
        "INSERT INTO mapping_audit_logs (mapping_id, action, performed_by, old_value, new_value) VALUES (?, ?, ?, ?, ?)",
        [mappingId, action, performedBy, JSON.stringify(oldValue), JSON.stringify(newValue)]
    );
}

exports.createMapping = async ({ teacher_id, section_id, subject_name, role, academic_year, performedBy }) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [result] = await connection.query(
            "INSERT INTO teacher_subject_mappings (teacher_id, section_id, subject_name, role, academic_year) VALUES (?, ?, ?, ?, ?)",
            [teacher_id, section_id, subject_name, role, academic_year]
        );

        const mappingId = result.insertId;
        await logAudit(connection, mappingId, 'CREATE', performedBy, null, { teacher_id, section_id, subject_name, role, academic_year });

        await connection.commit();
        return mappingId;
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};

exports.getMappings = async (filters = {}) => {
    let query = "SELECT m.*, t.name as teacher_name, s.class, s.section as section_name FROM teacher_subject_mappings m " +
        "JOIN teachers t ON m.teacher_id = t.id " +
        "JOIN sections s ON m.section_id = s.id WHERE m.is_active = TRUE";
    const params = [];

    if (filters.section_id) {
        query += " AND m.section_id = ?";
        params.push(filters.section_id);
    }
    if (filters.teacher_id) {
        query += " AND m.teacher_id = ?";
        params.push(filters.teacher_id);
    }

    const [rows] = await pool.query(query, params);
    return rows;
};

exports.deactivateMapping = async (id, performedBy) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const [oldValue] = await connection.query("SELECT * FROM teacher_subject_mappings WHERE id = ?", [id]);

        await connection.query("UPDATE teacher_subject_mappings SET is_active = FALSE WHERE id = ?", [id]);

        await logAudit(connection, id, 'DEACTIVATE', performedBy, oldValue[0], { is_active: false });

        await connection.commit();
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};
