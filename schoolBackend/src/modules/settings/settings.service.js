const pool = require("../../config/db");

exports.getSetting = async (key) => {
    const [rows] = await pool.query("SELECT value FROM school_settings WHERE key = ?", [key]);
    return rows.length > 0 ? rows[0].value : null;
};

exports.updateSetting = async (key, value) => {
    await pool.query(
        "INSERT INTO school_settings (key, value, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = CURRENT_TIMESTAMP",
        [key, value]
    );
    return true;
};

/**
 * Perform full academic year transition:
 * 1. Update global setting
 * 2. Promote all students to next class (9A → 10A, 10A → graduated)
 * 3. Update fees_structure academic_year
 * 4. Update active teacher_subject_mappings academic_year
 */
exports.performAcademicYearTransition = async (newYear) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Update global academic year setting
        await connection.query(
            "INSERT INTO school_settings (key, value, updated_at) VALUES ('current_academic_year', ?, CURRENT_TIMESTAMP) ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = CURRENT_TIMESTAMP",
            [newYear]
        );

        // 2. Fetch all sections to build promotion map
        // Sections have class (e.g. '9') and section (e.g. 'A')
        const [allSections] = await connection.query("SELECT id, class, section FROM sections");

        // Build a map: "class-section" → next_section_id
        // Promotion rule: class N + section X → section with class (N+1) and same section letter
        const sectionMap = {};
        allSections.forEach(s => {
            sectionMap[`${s.class}-${s.section}`] = s.id;
        });

        // 3. Fetch all students with their current class and section
        const [students] = await connection.query(
            "SELECT s.id, s.user_id, s.section_id, sec.class, sec.section FROM students s JOIN sections sec ON s.section_id = sec.id"
        );

        let promoted = 0;
        let graduated = 0;

        for (const student of students) {
            const currentClassNum = parseInt(student.class, 10);
            if (isNaN(currentClassNum)) continue; // Skip non-numeric class names

            const nextClassNum = currentClassNum + 1;
            const nextKey = `${nextClassNum}-${student.section}`;
            const nextSectionId = sectionMap[nextKey];

            if (nextSectionId) {
                // Promote to next class
                await connection.query(
                    "UPDATE students SET section_id = ?, academic_year = ? WHERE id = ?",
                    [nextSectionId, newYear, student.id]
                );
                promoted++;
            } else {
                // No next class found → student has graduated (mark as graduated or keep in last class)
                // We update academic_year and set a graduated flag if it exists, or just update academic_year
                await connection.query(
                    "UPDATE students SET academic_year = ? WHERE id = ?",
                    [newYear, student.id]
                );
                graduated++;
            }
        }

        // 4. Update fees_structure academic_year for all sections
        await connection.query(
            "UPDATE fees_structure SET academic_year = ?, updated_at = CURRENT_TIMESTAMP",
            [newYear]
        );

        // 5. Update active teacher_subject_mappings academic_year
        await connection.query(
            "UPDATE teacher_subject_mappings SET academic_year = ? WHERE is_active = 1",
            [newYear]
        );

        await connection.commit();

        return {
            year: newYear,
            students_promoted: promoted,
            students_graduated: graduated,
            total_students: students.length,
        };
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};
