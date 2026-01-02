const pool = require("../../config/db");

/**
 * Get students who messaged a teacher
 */
exports.getStudentsForTeacher = async (teacher_id) => {
  const [rows] = await pool.query(
    `
    SELECT DISTINCT
      u.id,
      s.name,
      s.roll_number
    FROM messages m
    JOIN students s ON s.user_id = m.student_id
    JOIN users u ON u.id = s.user_id
    WHERE m.teacher_id = ?
    `,
    [teacher_id]
  );

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
