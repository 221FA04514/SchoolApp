const pool = require("../../config/db");

/**
 * Teacher marks attendance
 */
exports.markAttendance = async ({ student_id, date, status, marked_by }) => {
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
 * Student fetches attendance by month
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
 * Attendance summary for student (month-wise)
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
 * Attendance calendar mapping
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
