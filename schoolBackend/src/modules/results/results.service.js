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
    ON CONFLICT (exam_id, student_id, subject) DO UPDATE
    SET
      marks = EXCLUDED.marks,
      grade = EXCLUDED.grade,
      remarks = EXCLUDED.remarks
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
      e.name as exam, e.exam_date, e.total_marks, e.passing_marks,
      e.class as exam_class,
      r.subject, r.marks, r.grade, r.remarks,
      r.created_at,
      CASE WHEN oe.id IS NOT NULL THEN 'Online' ELSE 'Offline' END as source
    FROM results r
    JOIN exams e ON r.exam_id = e.id
    LEFT JOIN online_exams oe ON oe.linked_exam_id = e.id
    WHERE r.student_id = ? AND e.is_published = 1
    ORDER BY e.exam_date DESC, r.created_at DESC
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
        ON CONFLICT (exam_id, student_id, subject) DO UPDATE
        SET
          marks = EXCLUDED.marks,
          grade = EXCLUDED.grade,
          remarks = EXCLUDED.remarks
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
    "SELECT id, name, class FROM sections ORDER BY class ASC, name ASC"
  );
  return rows;
};
/**
 * Get results for all students in a section for a specific exam
 */
exports.getStudentsWithMarks = async (examId, sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT 
      s.id, 
      s.name, 
      s.roll_no,
      r.marks,
      r.grade,
      r.remarks,
      r.id as result_id
    FROM students s
    LEFT JOIN results r ON s.id = r.student_id AND r.exam_id = ?
    WHERE s.section_id = ?
    ORDER BY s.roll_no ASC
    `,
    [examId, sectionId]
  );
  return rows;
};

/**
 * Verify if teacher is assigned to a subject in a section
 */
exports.verifyTeacherPermission = async (userId, examId, subjectName) => {
  const [teacher] = await pool.query("SELECT id FROM teachers WHERE user_id = ?", [userId]);
  if (!teacher[0]) return false;

  const [exam] = await pool.query("SELECT section_id FROM exams WHERE id = ?", [examId]);
  if (!exam[0]) return false;

  const [mapping] = await pool.query(
    "SELECT id FROM teacher_subject_mappings WHERE teacher_id = ? AND section_id = ? AND subject_name = ? AND is_active = 1",
    [teacher[0].id, exam[0].section_id, subjectName]
  );
  
  return mapping.length > 0;
};

/**
 * Get subjects allowed for a teacher in a section
 */
exports.getTeacherMappedSubjects = async (userId, sectionId) => {
  const [teacher] = await pool.query("SELECT id FROM teachers WHERE user_id = ?", [userId]);
  if (!teacher[0]) return [];

  const [mappings] = await pool.query(
    "SELECT subject_name FROM teacher_subject_mappings WHERE teacher_id = ? AND section_id = ? AND is_active = 1",
    [teacher[0].id, sectionId]
  );

  return mappings.map(m => m.subject_name);
};
