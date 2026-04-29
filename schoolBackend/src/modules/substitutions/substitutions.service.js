const pool = require("../../config/db");
const { createNotification } = require("../notifications/notifications.service");

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
    return rows;
};

/**
 * Returns all timetable periods for a teacher on a given date.
 * Used by the admin Whole-Day-Absent substitution flow.
 */
exports.getTeacherTimetableForDay = async (teacher_id, date) => {
    const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(new Date(date));

    // Resolve teacher name (timetable stores name string, not FK)
    const [teacherRows] = await pool.query(
        "SELECT name FROM teachers WHERE id = ?",
        [teacher_id]
    );
    if (teacherRows.length === 0) return [];
    const teacherName = teacherRows[0].name;

    const [rows] = await pool.query(
        `SELECT
             tt.period,
             tt.subject,
             TO_CHAR(tt.start_time, 'HH24:MI') AS start_time,
             TO_CHAR(tt.end_time,   'HH24:MI') AS end_time,
             tt.section_id,
             s.class    AS class_name,
             s.section  AS section_name
         FROM timetable tt
         JOIN sections s ON tt.section_id = s.id
         WHERE TRIM(tt.teacher_name) = TRIM(?) AND tt.day = ?
         ORDER BY tt.period`,
        [teacherName, dayName]
    );
    return rows;
};



exports.getSubstituteSuggestions = async (section_id, day, period, subject, date, absent_teacher_id) => {
    // 1. Find all teachers
    const [allTeachers] = await pool.query("SELECT id, name, subject FROM teachers");

    // 2. Find teachers who are busy in regular timetable (trim names to avoid whitespace mismatch)
    const [busyInTimetable] = await pool.query(
        "SELECT DISTINCT TRIM(teacher_name) as teacher_name FROM timetable WHERE day = ? AND period = ?",
        [day, period]
    );
    const busyTimetableNames = busyInTimetable.map(t => t.teacher_name.toLowerCase().trim());

    // 3. Find teachers who are ALREADY busy as substitutes today at this period
    const [busyInSubstitutions] = await pool.query(
        "SELECT DISTINCT substitute_teacher_id FROM substitutions WHERE date = ? AND period = ?",
        [date, period]
    );
    const busySubIds = busyInSubstitutions.map(t => t.substitute_teacher_id);

    // 4. Find teachers who are marked ABSENT today
    const [absentTeachers] = await pool.query(
        "SELECT DISTINCT teacher_id FROM teacher_absences WHERE absence_date = ?",
        [date]
    );
    const absentIds = absentTeachers.map(t => t.teacher_id);

    // 5. Also exclude the absent teacher by their explicit ID (passed from frontend)
    const absentTeacherId = absent_teacher_id ? parseInt(absent_teacher_id, 10) : null;

    // 6. Filter available teachers
    const available = allTeachers.filter(t => {
        const isBusyInTimetable = busyTimetableNames.includes(t.name.toLowerCase().trim());
        const isBusyInSub = busySubIds.includes(t.id);
        const isAbsent = absentIds.includes(t.id);
        // Explicitly exclude the absent teacher themselves
        const isTheAbsentTeacher = absentTeacherId && t.id === absentTeacherId;
        return !isBusyInTimetable && !isBusyInSub && !isAbsent && !isTheAbsentTeacher;
    });

    // 7. Rank by subject match
    return available.map(t => ({
        ...t,
        is_subject_match: t.subject?.toLowerCase().trim() === subject?.toLowerCase().trim()
    })).sort((a, b) => (b.is_subject_match ? 1 : 0) - (a.is_subject_match ? 1 : 0));
};

exports.assignSubstitution = async (data) => {
    let { absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks, absent_teacher_id } = data;

    // Map absent_teacher_id to original_teacher_id if missing
    if (!original_teacher_id && absent_teacher_id) {
        original_teacher_id = absent_teacher_id;
    }

    // 1. Resolve absence_id if missing
    if (!absence_id) {
        const [existingAbsence] = await pool.query(
            "SELECT id FROM teacher_absences WHERE teacher_id = ? AND absence_date = ?",
            [original_teacher_id, date]
        );
        if (existingAbsence.length > 0) {
            absence_id = existingAbsence[0].id;
        } else {
            const [newAbsence] = await pool.query(
                "INSERT INTO teacher_absences (teacher_id, absence_date, reason, marked_by) VALUES (?, ?, 'Auto-generated for Substitution', 1)",
                [original_teacher_id, date]
            );
            absence_id = newAbsence.insertId;
        }
    }

    // 2. Resolve section_id if missing
    if (!section_id) {
        const [teacherRows] = await pool.query("SELECT name FROM teachers WHERE id = ?", [original_teacher_id]);
        if (teacherRows.length === 0) throw new Error("Original teacher not found");
        const teacherName = teacherRows[0].name;

        const dayName = new Intl.DateTimeFormat('en-US', { weekday: 'long' }).format(new Date(date));

        const [timetableRows] = await pool.query(
            "SELECT section_id FROM timetable WHERE TRIM(teacher_name) = TRIM(?) AND day = ? AND period = ?",
            [teacherName, dayName, period]
        );

        if (timetableRows.length > 0) {
            section_id = timetableRows[0].section_id;
        } else {
            const [anyClass] = await pool.query(
                "SELECT section_id FROM timetable WHERE TRIM(teacher_name) = TRIM(?) LIMIT 1",
                [teacherName]
            );
            section_id = anyClass.length > 0 ? anyClass[0].section_id : 1;
        }
    }

    // 3. Insert Substitution
    const [result] = await pool.query(
        "INSERT INTO substitutions (absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [absence_id, date, period, section_id, original_teacher_id, substitute_teacher_id, remarks || '']
    );
    const substitutionId = result.insertId;

    // 4. Send in-app notification to the substitute teacher
    try {
        const [subTeacherRows] = await pool.query(
            "SELECT t.name, u.id as user_id FROM teachers t JOIN users u ON t.user_id = u.id WHERE t.id = ?",
            [substitute_teacher_id]
        );
        const [sectionRows] = await pool.query("SELECT class, section FROM sections WHERE id = ?", [section_id]);
        const [absentTeacherRows] = await pool.query("SELECT name FROM teachers WHERE id = ?", [original_teacher_id]);

        if (subTeacherRows.length > 0) {
            const subUserId = subTeacherRows[0].user_id;
            const className = sectionRows.length > 0 ? `${sectionRows[0].class}-${sectionRows[0].section}` : 'a class';
            const absentName = absentTeacherRows.length > 0 ? absentTeacherRows[0].name : 'a colleague';

            await createNotification(
                subUserId,
                '📋 Substitution Assigned',
                `You have been assigned to cover Period ${period} for ${absentName} in Class ${className} on ${date}. Please be prepared.`,
                'substitution'
            );
        }
    } catch (notifErr) {
        // Non-critical: log but don't fail the assignment
        console.error('[SUBSTITUTION] Failed to send notification:', notifErr.message);
    }

    return substitutionId;
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

exports.getMyTodaySubstitution = async (userId) => {
    const [[teacherRow]] = await pool.query(
        "SELECT id FROM teachers WHERE user_id = ?",
        [userId]
    );
    if (!teacherRow) return [];

    const today = new Date().toISOString().split('T')[0];
    const [rows] = await pool.query(
        `SELECT
             s.id,
             s.period,
             s.date,
             t_orig.name  AS original_teacher,
             sec.class    AS class_name,
             sec.section  AS section_name
         FROM substitutions s
         JOIN teachers  t_orig ON s.original_teacher_id  = t_orig.id
         JOIN sections  sec    ON s.section_id = sec.id
         WHERE s.substitute_teacher_id = ? AND s.date = ?
         ORDER BY s.period`,
        [teacherRow.id, today]
    );
    return rows;
};

exports.deleteSubstitution = async (id) => {
    const [result] = await pool.query(
        "DELETE FROM substitutions WHERE id = ?",
        [id]
    );
    return result.rowCount > 0 || result.affectedRows > 0;
};
