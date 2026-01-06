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
exports.getStudentHomework = async (sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT title, description, subject, due_date, created_at
    FROM homework
    WHERE section_id = ?
    ORDER BY due_date
    `,
    [sectionId]
  );

  return rows;
};
