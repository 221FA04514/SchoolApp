const pool = require("../../config/db");

/**
 * Teacher dashboard data
 */
exports.fetchTeacherDashboard = async (teacher_id) => {
  // 1. teacher basic info — join users for email, include phone
  const [tRows] = await pool.query(
    `SELECT t.name, t.subject, t.phone, u.email
     FROM teachers t
     JOIN users u ON t.user_id = u.id
     WHERE t.user_id = ?`,
    [teacher_id]
  );
  const teacher = tRows[0];

  // 2. total students handled
  const [sRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM students`
  );
  const students = sRows[0] || { total: 0 };

  // 3. pending doubts count
  const [dRows] = await pool.query(
    `SELECT COUNT(*) AS pending
     FROM messages
     WHERE teacher_id = ?
       AND sender = 'student'`,
    [teacher_id]
  );
  const doubts = dRows[0] || { pending: 0 };

  // 4. today's schedule — TRIM teacher_name to fix whitespace mismatches
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const today = days[new Date().getDay()];

  const [schedule] = await pool.query(
    `SELECT id, day, period, subject,
            TO_CHAR(start_time, 'HH24:MI') as start_time,
            TO_CHAR(end_time, 'HH24:MI') as end_time,
            section_id
     FROM timetable
     WHERE TRIM(teacher_name) = TRIM(?) AND day = ?
     ORDER BY period`,
    [teacher?.name || "", today]
  );

  return {
    teacher: {
      name:    teacher?.name    || "Unknown",
      subject: teacher?.subject || "General",
      phone:   teacher?.phone   || "",
      email:   teacher?.email   || "",
    },
    stats: {
      total_students: students.total,
      pending_doubts: doubts.pending,
    },
    today_schedule: schedule,
  };
};



exports.getStudentInfo = async (userId) => {
  const [rows] = await pool.query(
    `SELECT 
        id,
        name,
        class,
        section,
        roll_number
     FROM students
     WHERE user_id = ?`,
    [userId]
  );

  return rows[0];
};

// TEMP: latest announcements (limit 3)
exports.getLatestAnnouncements = async () => {
  const [rows] = await pool.query(
    `SELECT 
        id,
        title,
        description,
        created_at
     FROM announcements
     ORDER BY created_at DESC
     LIMIT 3`
  );

  return rows;
};
