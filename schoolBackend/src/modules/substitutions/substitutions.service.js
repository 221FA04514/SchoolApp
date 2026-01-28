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
    const { absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks } = data;
    const [result] = await pool.query(
        "INSERT INTO substitutions (absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks]
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
