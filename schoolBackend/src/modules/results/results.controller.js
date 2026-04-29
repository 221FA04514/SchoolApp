const pool = require("../../config/db");
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

    if (role !== "admin") {
      return error(res, "Access denied", 403);
    }

    if (!name || !exam_date || !section_id) {
      return error(res, "Name, Date, and Target Section are required", 400);
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

    const { verifyTeacherPermission } = require("./results.service");
    const hasPermission = await verifyTeacherPermission(req.user.userId, exam_id, subject);
    if (!hasPermission) {
      return error(res, "You are not authorized to enter marks for this subject in this section", 403);
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

    // Must fetch student_id from users.id
    const [student] = await pool.query("SELECT id FROM students WHERE user_id = ?", [userId]);
    if (!student[0]) return error(res, "Student record not found", 404);

    const results = await getStudentResults(student[0].id);
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

    if (role !== "teacher" && role !== "admin") {
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
    if (role !== "teacher" && role !== "admin") return error(res, "Access denied", 403);

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
    if (role !== "teacher" && role !== "admin") return error(res, "Access denied", 403);

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

    const { verifyTeacherPermission } = require("./results.service");
    const hasPermission = await verifyTeacherPermission(req.user.userId, exam_id, subject);
    if (!hasPermission) {
      return error(res, "You are not authorized to enter marks for this subject in this section", 403);
    }

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
    if (role !== "teacher" && role !== "admin") return error(res, "Access denied", 403);

    let exams;

    if (role === "admin") {
      // Admin sees ALL offline exams
      const [rows] = await pool.query(
        `SELECT e.*, s.name as section_name,
         (SELECT COUNT(*) FROM results WHERE exam_id = e.id) as marks_count
         FROM exams e
         LEFT JOIN sections s ON e.section_id = s.id
         WHERE e.class != 'Online'
         ORDER BY e.exam_date DESC`
      );
      exams = rows;
    } else {
      // Teacher sees all offline exams — marks entry is restricted by section mapping (verifyTeacherPermission)
      // We show ALL offline exams, and the marks entry screen will verify access
      const [teacherRec] = await pool.query("SELECT id FROM teachers WHERE user_id = ?", [userId]);
      const teacherId = teacherRec[0]?.id;

      const [rows] = await pool.query(
        `SELECT e.*, s.name as section_name,
         (SELECT COUNT(*) FROM results WHERE exam_id = e.id) as marks_count,
         CASE WHEN EXISTS (
           SELECT 1 FROM teacher_subject_mappings tsm
           WHERE tsm.teacher_id = ? AND tsm.section_id = e.section_id AND tsm.is_active = 1
         ) THEN 1 ELSE 0 END as can_enter_marks
         FROM exams e
         LEFT JOIN sections s ON e.section_id = s.id
         WHERE e.class != 'Online'
         ORDER BY e.exam_date DESC`,
        [teacherId]
      );
      exams = rows;
    }

    return success(res, exams, "Exams fetched");
  } catch (err) {
    next(err);
  }
};
/**
 * Get all marks for a specific exam and section
 */
exports.getExamMarks = async (req, res, next) => {
  try {
    const { examId, sectionId } = req.params;
    const { role } = req.user;
    if (role !== "teacher" && role !== "admin") return error(res, "Access denied", 403);

    const { getStudentsWithMarks } = require("./results.service");
    const students = await getStudentsWithMarks(examId, sectionId);
    return success(res, students, "Exam marks fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Get subjects assigned to teacher for a section
 */
exports.getTeacherSubjects = async (req, res, next) => {
  try {
    const { sectionId } = req.params;
    const { userId } = req.user;
    
    const { getTeacherMappedSubjects } = require("./results.service");
    const subjects = await getTeacherMappedSubjects(userId, sectionId);
    
    return success(res, subjects, "Teacher subjects fetched");
  } catch (err) {
    next(err);
  }
};
