const pool = require("../../config/db");

/**
 * Teacher creates exam
 */
exports.createExam = async ({ name, className, exam_date, created_by }) => {
  const [result] = await pool.query(
    `
    INSERT INTO exams (name, class, exam_date, created_by)
    VALUES (?, ?, ?, ?)
    `,
    [name, className, exam_date, created_by]
  );

  return result.insertId;
};

/**
 * Teacher uploads marks
 */
exports.uploadMarks = async ({
  exam_id,
  student_id,
  subject,
  marks,
}) => {
  await pool.query(
    `
    INSERT INTO results (exam_id, student_id, subject, marks)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      marks = VALUES(marks)
    `,
    [exam_id, student_id, subject, marks]
  );
};

/**
 * Student views results
 */
exports.getStudentResults = async (student_id) => {
  const [rows] = await pool.query(
    `
    SELECT 
      e.name AS exam,
      e.exam_date,
      r.subject,
      r.marks
    FROM results r
    JOIN exams e ON r.exam_id = e.id
    WHERE r.student_id = ?
    ORDER BY e.exam_date DESC
    `,
    [student_id]
  );

  return rows;
};
