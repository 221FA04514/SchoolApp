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
    const { role, userId } = req.user;
    const { name, className, exam_date } = req.body;

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
    const { exam_id, student_id, subject, marks } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!exam_id || !student_id || !subject || marks === undefined) {
      return error(res, "All fields are required", 400);
    }

    await uploadMarks({ exam_id, student_id, subject, marks });

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

    const results = await getStudentResults(userId);
    return success(res, results, "Results fetched");
  } catch (err) {
    next(err);
  }
};
