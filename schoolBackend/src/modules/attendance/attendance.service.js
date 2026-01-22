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
    ON DUPLICATE KEY UPDATE
      status = VALUES(status),
      marked_by = VALUES(marked_by)
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
      AND MONTH(date) = ?
      AND YEAR(date) = ?
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
      SUM(status = 'present') AS present,
      SUM(status = 'absent') AS absent,
      SUM(status = 'holiday') AS holiday,
      COUNT(*) AS total
    FROM attendance
    WHERE student_id = ?
      AND MONTH(date) = ?
      AND YEAR(date) = ?
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
 * Student: calendar mapping
 */
exports.getAttendanceCalendarMap = async (student_id, month, year) => {
  const [rows] = await pool.query(
    `
    SELECT date, status
    FROM attendance
    WHERE student_id = ?
      AND MONTH(date) = ?
      AND YEAR(date) = ?
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
