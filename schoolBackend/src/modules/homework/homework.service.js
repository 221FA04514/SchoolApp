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
}) => {
  const [result] = await pool.query(
    `
    INSERT INTO homework
      (title, description, subject, section_id, due_date, created_by)
    VALUES (?, ?, ?, ?, ?, ?)
    `,
    [title, description, subject, section_id, due_date, created_by]
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
           COALESCE(shs.is_completed, 0) as is_completed
    FROM homework h
    LEFT JOIN student_homework_status shs 
           ON shs.homework_id = h.id AND shs.student_id = ?
    WHERE h.section_id = ?
    ORDER BY h.due_date
    `,
    [studentId, sectionId]
  );

  return rows;
};

/**
 * Student: update homework status
 */
exports.updateHomeworkStatus = async (studentId, homeworkId, isCompleted) => {
  await pool.query(
    `
    INSERT INTO student_homework_status (student_id, homework_id, is_completed)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE is_completed = VALUES(is_completed)
    `,
    [studentId, homeworkId, isCompleted]
  );
  return { success: true };
};
