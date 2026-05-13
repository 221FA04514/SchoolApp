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
  needs_submission = true,
}) => {
  const [result] = await pool.query(
    `
    INSERT INTO homework
      (title, description, subject, section_id, due_date, created_by, is_offline, needs_submission)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [title, description, subject, section_id, due_date, created_by, is_offline, needs_submission]
  );

  return {
    id: result.insertId,
    title,
    description,
    subject,
    section_id,
    due_date,
    needs_submission,
  };
};

/**
 * Teacher: view homework posted by self
 */
exports.getTeacherHomework = async (teacherId) => {
  const [rows] = await pool.query(
    `
    SELECT h.id, h.title, h.description, h.subject, h.due_date, s.name AS section
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
    SELECT h.id, h.title, h.description, h.subject, h.due_date, h.created_at, h.needs_submission,
           COALESCE(shs.is_completed, 0) as is_completed,
           (SELECT marks FROM homework_submissions WHERE homework_id = h.id AND student_id = ? ORDER BY id DESC LIMIT 1) as marks,
           (SELECT feedback FROM homework_submissions WHERE homework_id = h.id AND student_id = ? ORDER BY id DESC LIMIT 1) as feedback,
           (SELECT status FROM homework_submissions WHERE homework_id = h.id AND student_id = ? ORDER BY id DESC LIMIT 1) as submission_status
    FROM homework h
    LEFT JOIN student_homework_status shs 
           ON shs.homework_id = h.id AND shs.student_id = ?
    WHERE h.section_id = ?
    ORDER BY h.created_at DESC
    `,
    [studentId, studentId, studentId, studentId, sectionId]
  );

  return rows;
};

/**
 * Student: get pending homework count
 */
exports.getPendingHomeworkCount = async (sectionId, studentId) => {
  const [rows] = await pool.query(
    `
    SELECT COUNT(*) as count
    FROM homework h
    LEFT JOIN student_homework_status shs 
           ON shs.homework_id = h.id AND shs.student_id = ?
    WHERE h.section_id = ? AND (shs.is_completed IS NULL OR shs.is_completed = 0)
    `,
    [studentId, sectionId]
  );

  return parseInt(rows[0]?.count || 0, 10);
};

/**
 * Student: get homework completion percentage
 */
exports.getHomeworkCompletion = async (sectionId, studentId) => {
  const [totalRows] = await pool.query(
    "SELECT COUNT(*) as count FROM homework WHERE section_id = ?",
    [sectionId]
  );
  const total = parseInt(totalRows[0]?.count || 0, 10);

  const [completedRows] = await pool.query(
    `SELECT COUNT(*) as count 
     FROM student_homework_status shs
     JOIN homework h ON shs.homework_id = h.id
     WHERE shs.student_id = ? AND h.section_id = ? AND shs.is_completed = 1`,
    [studentId, sectionId]
  );
  const completed = parseInt(completedRows[0]?.count || 0, 10);

  if (total === 0) return 0;
  return Math.round((completed / total) * 100);
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
exports.gradeSubmission = async (submissionId, { marks, feedback, status = 'approved' }) => {
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
