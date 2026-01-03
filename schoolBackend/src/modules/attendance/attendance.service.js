const pool = require("../../config/db");

/**
 * Teacher: get students list for attendance
 */
exports.getStudentsForTeacher = async () => {
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
 * Insert or update attendance (used by teacher)
 */
exports.upsertAttendance = async ({
  student_id,
  date,
  status,
  marked_by,
}) => {
  await pool.query(
    `
    INSERT INTO attendance (student_id, date, status, marked_by)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      status = VALUES(status),
      marked_by = VALUES(marked_by)
    `,
    [student_id, date, status, marked_by]
  );
};

/**
 * Teacher marks attendance for single student (existing API support)
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
 * Student fetches attendance (month-wise)
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
 * Student attendance summary
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

  const summary = rows[0];

  const workingDays = summary.total - summary.holiday;
  const percentage =
    workingDays > 0
      ? Math.round((summary.present / workingDays) * 100)
      : 0;

  return {
    present: Number(summary.present),
    absent: Number(summary.absent),
    holiday: Number(summary.holiday),
    total: Number(summary.total),
    percentage,
  };
};

/**
 * Attendance calendar mapping (student)
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

  const calendarMap = {};

  rows.forEach((row) => {
    const dateKey = row.date.toISOString().split("T")[0];
    calendarMap[dateKey] = row.status;
  });

  return calendarMap;
};
