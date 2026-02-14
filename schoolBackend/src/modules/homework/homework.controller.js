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

    const sectionId = rows[0].section_id;

    const homework = await getStudentHomework(sectionId, req.user.userId);
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

    await require("./homework.service").updateHomeworkStatus(
      req.user.userId,
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
/**
 * Student: submit homework
 */
exports.submitHomework = async (req, res, next) => {
  try {
    console.log("Submit Homework Request Headers:", req.headers["content-type"]);
    console.log("req.body:", req.body);
    console.log("req.file:", req.file);

    if (req.user.role !== "student") return error(res, "Access denied", 403);

<<<<<<< HEAD
=======
    // Ensure req.body is defined
    const body = req.body || {};
    const { homework_id, content } = body;
    let file_url = null;

    if (req.file) {
      // Store relative path or full URL depending on your preference.
      // Usually storing relative path like "uploads/filename.ext" is better.
      file_url = req.file.path.replace(/\\/g, "/"); // Normalize slashes
    }

>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
    await submitHomework({
      homework_id,
      student_id: req.user.userId,
      content,
      file_url,
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
