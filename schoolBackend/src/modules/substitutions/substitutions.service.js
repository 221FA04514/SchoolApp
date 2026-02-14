const pool = require("../../config/db");
// No direct groq import needed here, logic is currently internal

exports.markAbsent = async ({ teacher_id, absence_date, reason, marked_by }) => {
    const [result] = await pool.query(
        "INSERT INTO teacher_absences (teacher_id, absence_date, reason, marked_by) VALUES (?, ?, ?, ?)",
        [teacher_id, absence_date, reason, marked_by]
    );
    return result.insertId;
};

exports.getImpactedPeriods = async (teacher_id, date) => {
    const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(new Date(date));

    const [rows] = await pool.query(
        "SELECT * FROM timetable WHERE teacher_name = (SELECT name FROM teachers WHERE id = ?) AND day = ?",
        [teacher_id, dayName]
    );
    // Note: The legacy timetable uses 'teacher_name' (string). This is a limitation we must handle.
    return rows;
};

exports.getSubstituteSuggestions = async (section_id, day, period, subject) => {
    // 1. Find all teachers
    const [allTeachers] = await pool.query("SELECT id, name, subject FROM teachers");

    // 2. Find teachers who are FREE at this time
    const [busyTeachers] = await pool.query(
        "SELECT DISTINCT teacher_name FROM timetable WHERE day = ? AND period = ?",
        [day, period]
    );
    const busyNames = busyTeachers.map(t => t.teacher_name);

    // 3. Filter available teachers
    const available = allTeachers.filter(t => !busyNames.includes(t.name));

    // 4. Rank by subject match
    return available.map(t => ({
        ...t,
        is_subject_match: t.subject?.toLowerCase() === subject?.toLowerCase()
    })).sort((a, b) => (b.is_subject_match ? 1 : 0) - (a.is_subject_match ? 1 : 0));
};

exports.assignSubstitution = async (data) => {
<<<<<<< HEAD
    const { absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks } = data;
    const [result] = await pool.query(
        "INSERT INTO substitutions (absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks]
=======
    let { absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks, absent_teacher_id } = data;

    // Map absent_teacher_id to original_teacher_id if missing
    if (!original_teacher_id && absent_teacher_id) {
        original_teacher_id = absent_teacher_id;
    }

    // 1. Resolve absence_id if missing
    if (!absence_id) {
        // Check if exists
        const [existingAbsence] = await pool.query(
            "SELECT id FROM teacher_absences WHERE teacher_id = ? AND absence_date = ?",
            [original_teacher_id, date]
        );
        if (existingAbsence.length > 0) {
            absence_id = existingAbsence[0].id;
        } else {
            // Create new
            const [newAbsence] = await pool.query(
                "INSERT INTO teacher_absences (teacher_id, absence_date, reason, marked_by) VALUES (?, ?, 'Auto-generated for Substitution', 1)",
                [original_teacher_id, date]
            );
            absence_id = newAbsence.insertId;
        }
    }

    // 2. Resolve section_id if missing
    if (!section_id) {
        // Get teacher name
        const [teacherRows] = await pool.query("SELECT name FROM teachers WHERE id = ?", [original_teacher_id]);
        if (teacherRows.length === 0) throw new Error("Original teacher not found");
        const teacherName = teacherRows[0].name;

        // Get day name
        const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(new Date(date));

        // Find in timetable
        const [timetableRows] = await pool.query(
            "SELECT section_id FROM timetable WHERE teacher_name = ? AND day = ? AND period = ?",
            [teacherName, dayName, period]
        );

        if (timetableRows.length > 0) {
            section_id = timetableRows[0].section_id;
        } else {
            // Fallback: If no class at this specific time (e.g., Sunday), 
            // find ANY section this teacher teaches to satisfy the FK constraint.
            const [anyClass] = await pool.query(
                "SELECT section_id FROM timetable WHERE teacher_name = ? LIMIT 1",
                [teacherName]
            );
            if (anyClass.length > 0) {
                section_id = anyClass[0].section_id;
            } else {
                // Final Fallback: Use section_id = 1 (Assuming '1' exists) or throw error
                // Better to fail gracefully than crash.
                section_id = 1;
            }
        }
    }

    // 3. Insert Substitution
    const [result] = await pool.query(
        "INSERT INTO substitutions (absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks || '']
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    );
    return result.insertId;
};

exports.getSubstitutionsForDay = async (date) => {
    const [rows] = await pool.query(
        `SELECT sub.*, 
                t1.name as original_teacher, 
                t2.name as substitute_teacher,
                s.class, s.section as section_name
         FROM substitutions sub
         JOIN teachers t1 ON sub.original_teacher_id = t1.id
         JOIN teachers t2 ON sub.substitute_teacher_id = t2.id
         JOIN sections s ON sub.section_id = s.id
         WHERE sub.date = ?`,
        [date]
    );
    return rows;
};
