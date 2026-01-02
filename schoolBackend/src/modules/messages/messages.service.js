const pool = require("../../config/db");
exports.getTeachers = async () => {
  const [rows] = await pool.query(`
    SELECT u.id, t.name, t.subject
    FROM teachers t
    JOIN users u ON u.id = t.user_id
  `);
  return rows;
};
/**
 * Student sends doubt
 */
exports.sendStudentMessage = async ({
  student_id,
  teacher_id,
  message,
}) => {
  await pool.query(
    `
    INSERT INTO messages (student_id, teacher_id, sender, message)
    VALUES (?, ?, 'student', ?)
    `,
    [student_id, teacher_id, message]
  );
};

/**
 * Teacher replies to student
 */
exports.sendTeacherMessage = async ({
  student_id,
  teacher_id,
  message,
}) => {
  await pool.query(
    `
    INSERT INTO messages (student_id, teacher_id, sender, message)
    VALUES (?, ?, 'teacher', ?)
    `,
    [student_id, teacher_id, message]
  );
};

/**
 * Get conversation (student + teacher)
 */
exports.getConversation = async (student_id, teacher_id) => {
  const [rows] = await pool.query(
    `
    SELECT sender, message, created_at
    FROM messages
    WHERE student_id = ? AND teacher_id = ?
    ORDER BY created_at
    `,
    [student_id, teacher_id]
  );

  return rows;
};
