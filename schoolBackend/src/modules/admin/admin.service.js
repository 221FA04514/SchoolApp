const pool = require("../../config/db");

/**
 * Get all teachers
 */
exports.getAllTeachers = async () => {
    const [rows] = await pool.query(`
    SELECT t.id, u.id as user_id, u.email, t.name, t.subject, t.phone, 
           t.dob, t.joining_date, t.qualification, t.experience, t.address, t.created_at
    FROM users u 
    INNER JOIN teachers t ON u.id = t.user_id 
    WHERE u.role = 'teacher'
  `);

    return rows;
};


/**
 * Get all students
 */
exports.getAllStudents = async () => {
    const [rows] = await pool.query(`
    SELECT u.id as user_id, u.email, s.name, s.class, s.section, s.roll_number 
    FROM users u 
    LEFT JOIN students s ON u.id = s.user_id 
    WHERE u.role = 'student'
  `);
    return rows;
};

/**
 * Get all sections
 */
exports.getAllSections = async () => {
    const [rows] = await pool.query("SELECT * FROM sections ORDER BY name");
    return rows;
};

/**
 * Add a new section
 */
exports.addSection = async (className, section, name) => {
    const [result] = await pool.query(
        "INSERT INTO sections (class, section, name) VALUES (?, ?, ?)",
        [className, section, name]
    );
    return result.insertId;
};

exports.getPeriodSettings = async () => {
    // Corrected casting for Postgres TO_CHAR on VARCHAR columns
    const [rows] = await pool.query(
        `
        SELECT id, period_number, 
               TO_CHAR(start_time::time, 'HH24:MI') as start_time, 
               TO_CHAR(end_time::time, 'HH24:MI') as end_time 
        FROM period_settings 
        ORDER BY period_number
        `
    );
    return rows;
};

exports.updatePeriodSetting = async (periodNumber, startTime, endTime) => {
    await pool.query(
        `
        INSERT INTO period_settings (period_number, start_time, end_time)
        VALUES (?, ?, ?)
        ON CONFLICT (period_number) DO UPDATE
        SET
          start_time = EXCLUDED.start_time,
          end_time = EXCLUDED.end_time
        `,
        [periodNumber, startTime, endTime]
    );
};

exports.deletePeriodSetting = async (id) => {
    await pool.query("DELETE FROM period_settings WHERE id = ?", [id]);
};

/**
 * Archive the current timetable and clear it for a fresh start.
 */
exports.archiveCurrentTimetable = async () => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        const snapshotTag = `Snapshot_${new Date().toISOString().slice(0, 19).replace(/-/g, '').replace('T', '_')}`;
        
        // 1. Copy to archive
        await connection.query(`
            INSERT INTO archived_timetables (original_id, section_id, day, period, subject, teacher_name, start_time, end_time, snapshot_tag)
            SELECT id, section_id, day, period, subject, teacher_name, start_time, end_time, ? FROM timetable
        `, [snapshotTag]);

        // 2. Clear current timetable
        await connection.query("DELETE FROM timetable");

        await connection.commit();
        return { success: true, tag: snapshotTag };
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};

/**
 * Get suggestions from the last archived timetable for a specific slot.
 */
exports.getTimetableSuggestion = async (sectionId, day, period) => {
    const [rows] = await pool.query(`
        SELECT subject, teacher_name 
        FROM archived_timetables 
        WHERE section_id = ? AND day = ? AND period = ?
        ORDER BY archived_at DESC 
        LIMIT 1
    `, [sectionId, day, period]);
    return rows[0] || null;
};

/**
 * Check if the active timetable has assignments.
 */
exports.isTimetableEmpty = async () => {
    const [rows] = await pool.query("SELECT COUNT(*) as count FROM timetable");
    return Number(rows[0].count) === 0;
};

/**
 * Get distinct archive batches.
 */
exports.getArchiveList = async () => {
    const [rows] = await pool.query(`
        SELECT snapshot_tag, MAX(archived_at) as archived_at, COUNT(*) as record_count 
        FROM archived_timetables 
        GROUP BY snapshot_tag 
        ORDER BY archived_at DESC
    `);
    return rows.map(r => ({
        ...r,
        record_count: Number(r.record_count)
    }));
};

/**
 * Get full timetable for a specific snapshot.
 */
exports.getArchiveByTag = async (tag) => {
    const [rows] = await pool.query(`
        SELECT section_id, day, period, subject, teacher_name, 
               TO_CHAR(start_time, 'HH24:MI') as start_time, 
               TO_CHAR(end_time, 'HH24:MI') as end_time 
        FROM archived_timetables 
        WHERE snapshot_tag = ?
        ORDER BY section_id, period
    `, [tag]);
    return rows;
};


/**
 * Delete a section
 */
exports.deleteSection = async (id) => {
    await pool.query("DELETE FROM sections WHERE id = ?", [id]);
};

/**
 * Update teacher details
 */
exports.updateTeacher = async (userId, data) => {
    const { name, subject, phone } = data;
    await pool.query(
        "UPDATE teachers SET name = ?, subject = ?, phone = ? WHERE user_id = ?",
        [name, subject, phone, userId]
    );
};

/**
 * Update student details
 */
exports.updateStudent = async (userId, data) => {
    const { name, class: className, section, roll_number } = data;
    await pool.query(
        "UPDATE students SET name = ?, class = ?, section = ?, roll_number = ? WHERE user_id = ?",
        [name, className, section, roll_number, userId]
    );
};

/**
 * Update user email and optionally password
 */
exports.updateUserAccount = async (userId, email, hashedPassword = null) => {
    if (hashedPassword) {
        await pool.query(
            "UPDATE users SET email = ?, password = ? WHERE id = ?",
            [email, hashedPassword, userId]
        );
    } else {
        await pool.query(
            "UPDATE users SET email = ? WHERE id = ?",
            [email, userId]
        );
    }
};

/**
 * Get section-wise analytics for Attendance and Fees
 */
exports.getSectionWiseAnalytics = async () => {
    // 1. Attendance Analytics (Percentage per section for current month)
    const [attendanceRows] = await pool.query(`
        SELECT 
            s.name as section_name,
            COUNT(a.id) as total_records,
            COALESCE(SUM(CASE WHEN LOWER(a.status) = 'present' THEN 1 ELSE 0 END), 0) as present_count
        FROM sections s
        LEFT JOIN students st ON s.id = st.section_id
        LEFT JOIN attendance a ON st.user_id = a.student_id AND EXTRACT(MONTH FROM a.date) = EXTRACT(MONTH FROM CURRENT_DATE)
        GROUP BY s.id, s.name
        ORDER BY s.name
    `);

    const attendanceData = attendanceRows.map(row => ({
        section: row.section_name,
        percentage: row.total_records > 0 ? Math.round((row.present_count / row.total_records) * 100) : 0
    }));

    // 2. Fees Analytics (Refined: Ensuring all sections are returned via outer join)
    const [feeRows] = await pool.query(`
        SELECT 
            s.name as section_name,
            COALESCE(SUM(f.total_amount), 0) as total_expected,
            (
                SELECT COALESCE(SUM(fp.amount_paid), 0)
                FROM fee_payments fp 
                JOIN students st2 ON fp.student_id = st2.user_id 
                WHERE st2.section_id = s.id
            ) as total_paid
        FROM sections s
        LEFT JOIN students st ON s.id = st.section_id
        LEFT JOIN fees f ON st.user_id = f.student_id
        GROUP BY s.id, s.name
        ORDER BY s.name
    `);

    const feeData = feeRows.map(row => {
        const expected = Number(row.total_expected);
        const paid = Number(row.total_paid);
        const percentage = expected > 0 ? Math.round((paid / expected) * 100) : 0;
        return {
            section: row.section_name,
            paid: paid,
            pending: Math.max(0, expected - paid),
            total: expected,
            percentage: percentage
        };
    });

    return {
        attendance: attendanceData,
        fees: feeData
    };
};
