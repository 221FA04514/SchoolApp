const { success, error } = require("../../utils/response");
const {
  createHomework,
  getTeacherHomework,
  getStudentHomework,
} = require("./homework.service");
const pool = require("../../config/db");

/**
 * Teacher: create homework
 */
exports.createHomework = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { title, description, subject, section_id, due_date } = req.body;

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

    const homework = await getStudentHomework(rows[0].section_id);
    return success(res, homework, "Homework fetched");
  } catch (err) {
    next(err);
  }
};
