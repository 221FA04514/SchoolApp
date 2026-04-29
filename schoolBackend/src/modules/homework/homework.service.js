const pool = require("../../config/db");

/**
 * Teacher: create homework
 */
exports.createHomework = async ({
  title,
  description,
  subject,
  section_id,
  due_date,
  created_by,
  is_offline = false,
}) => {
  const [result] = await pool.query(
    `
    INSERT INTO homework
      (title, description, subject, section_id, due_date, created_by, is_offline)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
    [title, description, subject, section_id, due_date, created_by, is_offline]
  );

  return {
    id: result.insertId,
    title,
    description,
    subject,
    section_id,
    due_date,
  };
};

/**
 * Teacher: view homework posted by self
 */
exports.getTeacherHomework = async (teacherId) => {
  const [rows] = await pool.query(
    `
    SELECT h.id, h.title, h.subject, h.due_date, s.name AS section
    FROM homework h
    JOIN sections s ON s.id = h.section_id
    WHERE h.created_by = ?
    ORDER BY h.created_at DESC
    `,
    [teacherId]
  );

  return rows;
};

/**
 * Student: view homework (section-wise)
 */
exports.getStudentHomework = async (sectionId, studentId) => {
  const [rows] = await pool.query(
    `
    SELECT h.id, h.title, h.description, h.subject, h.due_date, h.created_at,
           COALESCE(shs.is_completed, 0) as is_completed,
           hs.marks, hs.feedback, hs.status as submission_status
    FROM homework h
    LEFT JOIN student_homework_status shs 
           ON shs.homework_id = h.id AND shs.student_id = ?
    LEFT JOIN homework_submissions hs
           ON hs.homework_id = h.id AND hs.student_id = ?
    WHERE h.section_id = ?
    ORDER BY h.created_at DESC
    `,
    [studentId, studentId, sectionId]
  );

  return rows;
};

/**
 * Student: get pending homework count
 */
exports.getPendingHomeworkCount = async (sectionId, studentId) => {
  const [[result]] = await pool.query(
    `
    SELECT COUNT(*) as count
    FROM homework h
    LEFT JOIN student_homework_status shs 
           ON shs.homework_id = h.id AND shs.student_id = ?
    WHERE h.section_id = ? AND (shs.is_completed IS NULL OR shs.is_completed = 0)
    `,
    [studentId, sectionId]
  );

  return result.count;
};

/**
 * Student: get homework completion percentage
 */
exports.getHomeworkCompletion = async (sectionId, studentId) => {
  const [[total]] = await pool.query(
    "SELECT COUNT(*) as count FROM homework WHERE section_id = ?",
    [sectionId]
  );
  const [[completed]] = await pool.query(
    `SELECT COUNT(*) as count 
     FROM student_homework_status shs
     JOIN homework h ON shs.homework_id = h.id
     WHERE shs.student_id = ? AND h.section_id = ? AND shs.is_completed = 1`,
    [studentId, sectionId]
  );

  if (total.count === 0) return 0;
  return Math.round((completed.count / total.count) * 100);
};

/**
 * Student: update homework status
 */
exports.updateHomeworkStatus = async (studentId, homeworkId, isCompleted) => {
  await pool.query(
    `
    INSERT INTO student_homework_status (student_id, homework_id, is_completed)
    VALUES (?, ?, ?)
    ON CONFLICT (student_id, homework_id) DO UPDATE
    SET is_completed = EXCLUDED.is_completed
    `,
    [studentId, homeworkId, isCompleted]
  );
  return { success: true };
};

/**
 * Student: submit homework
 */
exports.submitHomework = async ({ homework_id, student_id, content, file_url }) => {
  const [result] = await pool.query(
    `
    INSERT INTO homework_submissions (homework_id, student_id, content, file_url, status)
    VALUES (?, ?, ?, ?, 'pending')
    `,
    [homework_id, student_id, content, file_url]
  );
  return result.insertId;
};

/**
 * Teacher: get submission stats
 */
exports.getSubmissionStats = async (homework_id) => {
  const [rows] = await pool.query(
    `
    SELECT 
      hs.*, 
      s.name as student_name
    FROM homework_submissions hs
    JOIN students s ON hs.student_id = s.user_id
    WHERE hs.homework_id = ?
    `,
    [homework_id]
  );
  return rows;
};

/**
 * Grade a submission
 */
exports.gradeSubmission = async (submissionId, { marks, feedback, status = 'graded' }) => {
  await pool.query(
    `UPDATE homework_submissions SET marks = ?, feedback = ?, status = ? WHERE id = ?`,
    [marks, feedback, status, submissionId]
  );
};

/**
 * Delete Homework
 */
exports.deleteHomework = async (homeworkId, teacherId) => {
  await pool.query(`DELETE FROM homework_submissions WHERE homework_id = ?`, [homeworkId]);
  await pool.query(`DELETE FROM student_homework_status WHERE homework_id = ?`, [homeworkId]);
  await pool.query(`DELETE FROM homework WHERE id = ? AND created_by = ?`, [homeworkId, teacherId]);
};
