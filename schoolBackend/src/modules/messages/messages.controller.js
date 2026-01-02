const { success, error } = require("../../utils/response");
const {
  sendStudentMessage,
  sendTeacherMessage,
  getConversation,
  getStudentsForTeacher,
} = require("./messages.service");

/**
 * Get students list (for teacher)
 */
exports.getStudentsForTeacher = async (req, res, next) => {
  try {
    const { role, userId } = req.user;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const students = await getStudentsForTeacher(userId);
    return success(res, students, "Students fetched");
  } catch (err) {
    next(err);
  }
};


/**
 * Student sends doubt
 */
exports.studentSendMessage = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { teacher_id, message } = req.body;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    if (!teacher_id || !message) {
      return error(res, "All fields are required", 400);
    }

    await sendStudentMessage({
      student_id: userId,
      teacher_id,
      message,
    });

    return success(res, null, "Message sent");
  } catch (err) {
    next(err);
  }
};

/**
 * Get teachers list (for student to select)
 */
exports.getTeachersForStudent = async (req, res, next) => {
  try {
    const pool = require("../../config/db");

    const [rows] = await pool.query(`
      SELECT u.id, t.name, t.subject
      FROM teachers t
      JOIN users u ON u.id = t.user_id
    `);

    return success(res, rows, "Teachers fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher replies
 */
exports.teacherSendMessage = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { student_id, message } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!student_id || !message) {
      return error(res, "All fields are required", 400);
    }

    await sendTeacherMessage({
      student_id,
      teacher_id: userId,
      message,
    });

    return success(res, null, "Reply sent");
  } catch (err) {
    next(err);
  }
};

/**
 * Get conversation
 */
exports.getMessages = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { student_id, teacher_id } = req.query;

    // student views own conversation
    if (role === "student") {
      return success(
        res,
        await getConversation(userId, teacher_id),
        "Messages fetched"
      );
    }

    // teacher views student's conversation
    if (role === "teacher") {
      return success(
        res,
        await getConversation(student_id, userId),
        "Messages fetched"
      );
    }

    return error(res, "Access denied", 403);
  } catch (err) {
    next(err);
  }
};
