const pool = require("../../config/db");

/**
 * Teacher creates exam
 */
exports.createExam = async ({ name, className, exam_date, section_id, total_marks = 100, passing_marks = 35, created_by }) => {
  const [result] = await pool.query(
    `
    INSERT INTO exams (name, class, exam_date, section_id, total_marks, passing_marks, created_by)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
    [name, className, exam_date, section_id, total_marks, passing_marks, created_by]
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
  grade,
  remarks,
}) => {
  await pool.query(
    `
    INSERT INTO results (exam_id, student_id, subject, marks, grade, remarks)
    VALUES (?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      marks = VALUES(marks),
      grade = VALUES(grade),
      remarks = VALUES(remarks)
    `,
    [exam_id, student_id, subject, marks, grade, remarks]
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
      e.total_marks,
      e.passing_marks,
      r.subject,
      r.marks,
      r.grade,
      r.remarks
    FROM results r
    JOIN exams e ON r.exam_id = e.id
    WHERE r.student_id = ? AND e.is_published = TRUE
    ORDER BY e.exam_date DESC
    `,
    [student_id]
  );

  return rows;
};

/**
 * Get students for a section (for marking)
 */
exports.getStudentsBySection = async (sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT s.id, s.name, s.roll_no, s.user_id
    FROM students s
    WHERE s.section_id = ?
    ORDER BY s.roll_no ASC
    `,
    [sectionId]
  );
  return rows;
};

/**
 * Bulk upload marks
 */
exports.bulkUploadMarks = async ({ exam_id, subject, marks_list }) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    for (const item of marks_list) {
      await connection.query(
        `
        INSERT INTO results (exam_id, student_id, subject, marks, grade, remarks)
        VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
          marks = VALUES(marks),
          grade = VALUES(grade),
          remarks = VALUES(remarks)
        `,
        [exam_id, item.student_id, subject, item.marks, item.grade, item.remarks]
      );
    }

    await connection.commit();
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

/**
 * Get sections handled by teacher
 */
exports.getTeacherSections = async (teacherId) => {
  const [rows] = await pool.query(
    `
    SELECT DISTINCT s.id, s.name
    FROM sections s
    JOIN students std ON std.section_id = s.id
    -- This is a simplification. Usually there is a teacher_sections mapping.
    -- For now, we fetch all sections since we don't have a direct mapping table.
    `
  );
  return rows;
};
