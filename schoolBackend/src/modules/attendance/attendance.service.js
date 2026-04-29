const pool = require("../../config/db");

/**
 * Teacher: get students list
 * - If sectionId provided → section wise
 * - Else → all students (BACKWARD COMPATIBLE)
 */
exports.getStudentsForTeacher = async (sectionId = null) => {
  if (sectionId) {
    const [rows] = await pool.query(
      `
      SELECT 
        u.id AS student_id,
        s.name,
        s.roll_number
      FROM students s
      JOIN users u ON u.id = s.user_id
      WHERE s.section_id = ?
      ORDER BY s.roll_number
      `,
      [sectionId]
    );
    return rows;
  }

  const [rows] = await pool.query(`
    SELECT 
      u.id AS student_id,
      s.name,
      s.roll_number
    FROM students s
    JOIN users u ON u.id = s.user_id
    ORDER BY s.roll_number
  `);

  return rows;
};

/**
 * Insert or update attendance
 */
exports.upsertAttendance = async ({
  student_id,
  date,
  status,
  marked_by,
}) => {
  // Get old status if exists
  const [existing] = await pool.query(
    "SELECT id, status FROM attendance WHERE student_id = ? AND date = ?",
    [student_id, date]
  );

  const [result] = await pool.query(
    `
    INSERT INTO attendance (student_id, date, status, marked_by)
    VALUES (?, ?, ?, ?)
    ON CONFLICT (student_id, date) DO UPDATE
    SET
      status = EXCLUDED.status,
      marked_by = EXCLUDED.marked_by
    `,
    [student_id, date, status, marked_by]
  );

  // Audit trail
  if (existing.length > 0 && existing[0].status !== status) {
    await pool.query(
      "INSERT INTO attendance_audit (attendance_id, old_status, new_status, changed_by) VALUES (?, ?, ?, ?)",
      [existing[0].id, existing[0].status, status, marked_by]
    );
  }
};

/**
 * Get attendance audit history
 */
exports.getAttendanceHistory = async (student_id, date) => {
  const [rows] = await pool.query(
    `
    SELECT a.old_status, a.new_status, a.changed_at, u.name as changed_by_name
    FROM attendance_audit a
    JOIN attendance att ON a.attendance_id = att.id
    JOIN users u ON a.changed_by = u.id
    WHERE att.student_id = ? AND att.date = ?
    ORDER BY a.changed_at DESC
    `,
    [student_id, date]
  );
  return rows;
};

/**
 * Single student attendance (teacher)
 */
exports.markAttendance = async ({
  student_id,
  date,
  status,
  marked_by,
}) => {
  await exports.upsertAttendance({
    student_id,
    date,
    status,
    marked_by,
  });
};

/**
 * Student: fetch attendance
 */
exports.getStudentAttendance = async (student_id, month, year) => {
  const [rows] = await pool.query(
    `
    SELECT date, status
    FROM attendance
    WHERE student_id = ?
      AND EXTRACT(MONTH FROM date) = ?
      AND EXTRACT(YEAR FROM date) = ?
    ORDER BY date
    `,
    [student_id, month, year]
  );
  return rows;
};

/**
 * Student: attendance summary
 */
exports.getAttendanceSummary = async (student_id, month, year) => {
  const [rows] = await pool.query(
    `
    SELECT
      COALESCE(SUM(CASE WHEN LOWER(status) = 'present' THEN 1 ELSE 0 END), 0) AS present,
      COALESCE(SUM(CASE WHEN LOWER(status) = 'absent' THEN 1 ELSE 0 END), 0) AS absent,
      COALESCE(SUM(CASE WHEN LOWER(status) = 'holiday' THEN 1 ELSE 0 END), 0) AS holiday,
      COUNT(*) AS total
    FROM attendance
    WHERE student_id = ?
      AND EXTRACT(MONTH FROM date) = ?
      AND EXTRACT(YEAR FROM date) = ?
    `,
    [student_id, month, year]
  );

  const s = rows[0];
  const workingDays = s.total - s.holiday;
  const percentage =
    workingDays > 0
      ? Math.round((s.present / workingDays) * 100)
      : 0;

  return {
    present: Number(s.present),
    absent: Number(s.absent),
    holiday: Number(s.holiday),
    total: Number(s.total),
    percentage,
  };
};

/**
 * Student: overall attendance summary
 */
exports.getOverallAttendanceSummary = async (student_id) => {
  const [rows] = await pool.query(
    `
    SELECT
      COALESCE(SUM(CASE WHEN LOWER(status) = 'present' THEN 1 ELSE 0 END), 0) AS present,
      COALESCE(SUM(CASE WHEN LOWER(status) = 'absent' THEN 1 ELSE 0 END), 0) AS absent,
      COALESCE(SUM(CASE WHEN LOWER(status) = 'holiday' THEN 1 ELSE 0 END), 0) AS holiday,
      COUNT(*) AS total
    FROM attendance
    WHERE student_id = ?
    `,
    [student_id]
  );

  const s = rows[0];
  const workingDays = s.total - (s.holiday || 0);
  const percentage =
    workingDays > 0
      ? Math.round(((s.present || 0) / workingDays) * 100)
      : 0;

  return {
    present: Number(s.present || 0),
    absent: Number(s.absent || 0),
    holiday: Number(s.holiday || 0),
    total: Number(s.total || 0),
    percentage,
  };
};

/**
 * Student: calendar mapping
 */
exports.getAttendanceCalendarMap = async (student_id, month, year) => {
  const [rows] = await pool.query(
    `
    SELECT date, status
    FROM attendance
    WHERE student_id = ?
      AND EXTRACT(MONTH FROM date) = ?
      AND EXTRACT(YEAR FROM date) = ?
    `,
    [student_id, month, year]
  );

  const map = {};
  rows.forEach((r) => {
    const d = new Date(r.date);
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    map[`${y}-${m}-${day}`] = r.status;
  });

  return map;
};
