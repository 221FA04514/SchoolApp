const { success, error } = require("../../utils/response");
const {
  createExam,
  uploadMarks,
  getStudentResults,
} = require("./results.service");

/**
 * Teacher creates exam
 */
exports.createExam = async (req, res, next) => {
  try {
    const { userId, role } = req.user;
    const { name, className, exam_date, section_id, total_marks, passing_marks } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!name || !className || !exam_date) {
      return error(res, "All fields are required", 400);
    }

    const examId = await createExam({
      name,
      className,
      exam_date,
      section_id,
      total_marks,
      passing_marks,
      created_by: userId,
    });

    return success(res, { examId }, "Exam created");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher uploads marks
 */
exports.uploadMarks = async (req, res, next) => {
  try {
    const { role } = req.user;
    const { exam_id, student_id, subject, marks, grade, remarks } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!exam_id || !student_id || !subject || marks === undefined) {
      return error(res, "All fields are required", 400);
    }

    await uploadMarks({ exam_id, student_id, subject, marks, grade, remarks });

    return success(res, null, "Marks uploaded");
  } catch (err) {
    next(err);
  }
};

/**
 * Student views results
 */
exports.getMyResults = async (req, res, next) => {
  try {
    const { role, userId } = req.user;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    // Resolve studentId
    const pool = require("../../config/db");
    const [rows] = await pool.query(
      `SELECT id FROM students WHERE user_id = ?`,
      [userId]
    );

    if (!rows.length) {
      return error(res, "Student not found", 404);
    }
    const studentId = rows[0].id;

    const results = await getStudentResults(studentId);
    return success(res, results, "Results fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: Toggle exam result visibility
 */
exports.togglePublish = async (req, res, next) => {
  try {
    const { role } = req.user;
    const { examId, isPublished } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    await pool.query(
      "UPDATE exams SET is_published = ? WHERE id = ?",
      [isPublished, examId]
    );

    return success(res, null, `Exam ${isPublished ? 'published' : 'unpublished'} successfully`);
  } catch (err) {
    next(err);
  }
};

/**
 * Get sections
 */
exports.getSections = async (req, res, next) => {
  try {
    const { role } = req.user;
    if (role !== "teacher") return error(res, "Access denied", 403);

    const { getTeacherSections } = require("./results.service");
    const sections = await getTeacherSections(req.user.userId);
    return success(res, sections, "Sections fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Get students in section
 */
exports.getSectionStudents = async (req, res, next) => {
  try {
    const { sectionId } = req.params;
    const { role } = req.user;
    if (role !== "teacher") return error(res, "Access denied", 403);

    const { getStudentsBySection } = require("./results.service");
    const students = await getStudentsBySection(sectionId);
    return success(res, students, "Students fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Bulk upload marks
 */
exports.bulkUploadMarks = async (req, res, next) => {
  try {
    const { role } = req.user;
    const { exam_id, subject, marks_list } = req.body;

    if (role !== "teacher") return error(res, "Access denied", 403);

    const { bulkUploadMarks } = require("./results.service");
    await bulkUploadMarks({ exam_id, subject, marks_list });

    return success(res, null, "Bulk marks uploaded successfully");
  } catch (err) {
    next(err);
  }
};
/**
 * Get all exams (for teacher)
 */
exports.listExams = async (req, res, next) => {
  try {
    const { userId, role } = req.user;
    if (role !== "teacher") return error(res, "Access denied", 403);

    const [exams] = await pool.query(
      `SELECT e.*, 
       (SELECT COUNT(*) FROM results WHERE exam_id = e.id) as marks_count
       FROM exams e 
       ORDER BY e.exam_date DESC`
    );
    return success(res, exams, "Exams fetched");
  } catch (err) {
    next(err);
  }
};
