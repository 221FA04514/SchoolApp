const { success, error } = require("../../utils/response");
const {
  createHomework,
  getTeacherHomework,
  getStudentHomework,
  submitHomework,
  getSubmissionStats,
  gradeSubmission,
} = require("./homework.service");
const pool = require("../../config/db");

/**
 * Teacher: create homework
 */
exports.createHomework = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { title, description, subject, section_id, due_date, is_offline } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!title || !description || !subject || !section_id || !due_date) {
      return error(res, "All fields are required", 400);
    }

    const homework = await createHomework({
      title,
      description,
      subject,
      section_id,
      due_date,
      created_by: userId,
      is_offline: is_offline || false,
    });

    return success(res, homework, "Homework created");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: view own homework
 */
exports.getMyHomework = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const data = await getTeacherHomework(req.user.userId);
    return success(res, data, "Homework fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Student: view homework (section-wise)
 */
exports.getHomeworkForStudent = async (req, res, next) => {
  try {
    if (req.user.role !== "student") {
      return error(res, "Access denied", 403);
    }

    // get student's section_id
    const [rows] = await pool.query(
      `SELECT section_id FROM students WHERE user_id = ?`,
      [req.user.userId]
    );

    if (!rows.length) {
      return error(res, "Student not found", 404);
    }

    // Pass student's userId (which is req.user.userId from token) 
    // Wait, students table has 'id' which is studentId. 'user_id' is from users table.
    // We need studentId. 
    // The query above fetches section_id. Let's fetch the student ID as well.
    const [studentRows] = await pool.query(
      `SELECT id, section_id FROM students WHERE user_id = ?`,
      [req.user.userId]
    );
    if (!studentRows.length) {
      return error(res, "Student not found", 404);
    }

    const studentId = studentRows[0].id;
    const sectionId = studentRows[0].section_id;

    const homework = await getStudentHomework(sectionId, studentId);
    return success(res, homework, "Homework fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Student: mark homework status
 */
exports.markHomeworkStatus = async (req, res, next) => {
  try {
    if (req.user.role !== "student") {
      return error(res, "Access denied", 403);
    }

    const { homework_id, is_completed } = req.body;

    // Get student ID
    const [rows] = await pool.query(
      `SELECT id FROM students WHERE user_id = ?`,
      [req.user.userId]
    );

    if (!rows.length) {
      return error(res, "Student not found", 404);
    }
    const studentId = rows[0].id;

    await require("./homework.service").updateHomeworkStatus(
      studentId,
      homework_id,
      is_completed
    );

    return success(res, null, "Status updated");
  } catch (err) {
    next(err);
  }
};
/**
 * Student: submit homework
 */
exports.submitHomework = async (req, res, next) => {
  try {
    if (req.user.role !== "student") return error(res, "Access denied", 403);
    const { homework_id, content, file_url } = req.body;

    // Resolve studentId
    const [rows] = await pool.query(
      `SELECT id FROM students WHERE user_id = ?`,
      [req.user.userId]
    );

    if (!rows.length) {
      return error(res, "Student not found", 404);
    }
    const studentId = rows[0].id;

    await submitHomework({
      homework_id,
      student_id: studentId,
      content,
      file_url
    });

    return success(res, null, "Homework submitted successfully");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: get submissions
 */
exports.getSubmissions = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") return error(res, "Access denied", 403);
    const { homework_id } = req.params;

    const submissions = await getSubmissionStats(homework_id);
    return success(res, submissions, "Submissions fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: grade homework
 */
exports.gradeHomework = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") return error(res, "Access denied", 403);
    const { submission_id, marks, feedback, status } = req.body;

    await gradeSubmission(submission_id, { marks, feedback, status });
    return success(res, null, "Homework graded");
  } catch (err) {
    next(err);
  }
};
