const pool = require("../../config/db");

/**
 * Teacher dashboard data
 */
exports.fetchTeacherDashboard = async (teacher_id) => {
  // teacher basic info
  const [[teacher]] = await pool.query(
    `
    SELECT name, subject
    FROM teachers
    WHERE user_id = ?
    `,
    [teacher_id]
  );

  // total students handled (basic count)
  const [[students]] = await pool.query(
    `
    SELECT COUNT(*) AS total
    FROM students
    `
  );

  // pending doubts count
  const [[doubts]] = await pool.query(
    `
    SELECT COUNT(*) AS pending
    FROM messages
    WHERE teacher_id = ?
      AND sender = 'student'
    `,
    [teacher_id]
  );

  return {
    teacher: {
      name: teacher?.name || "",
      subject: teacher?.subject || "",
    },
    stats: {
      total_students: students.total,
      pending_doubts: doubts.pending,
    },
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
