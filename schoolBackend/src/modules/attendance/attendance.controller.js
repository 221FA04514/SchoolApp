const { success, error } = require("../../utils/response");
const {
  markAttendance,
  getStudentAttendance,
  getAttendanceSummary,
  getAttendanceCalendarMap,
} = require("./attendance.service");


/**
 * Teacher marks attendance
 */
exports.markStudentAttendance = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { student_id, date, status } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!student_id || !date || !status) {
      return error(res, "All fields are required", 400);
    }

    await markAttendance({
      student_id,
      date,
      status,
      marked_by: userId,
    });

    return success(res, null, "Attendance marked successfully");
  } catch (err) {
    next(err);
  }
};

/**
 * Student views attendance
 */
exports.getMyAttendance = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { month, year } = req.query;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    const attendance = await getStudentAttendance(userId, month, year);

    return success(res, attendance, "Attendance fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Student attendance calendar mapping
 */
exports.getMyAttendanceCalendar = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { month, year } = req.query;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    if (!month || !year) {
      return error(res, "Month and year are required", 400);
    }

    const calendar = await getAttendanceCalendarMap(userId, month, year);

    return success(res, calendar, "Attendance calendar fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Student attendance summary
 */
exports.getMyAttendanceSummary = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { month, year } = req.query;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    if (!month || !year) {
      return error(res, "Month and year are required", 400);
    }

    const summary = await getAttendanceSummary(userId, month, year);

    return success(res, summary, "Attendance summary fetched");
  } catch (err) {
    next(err);
  }
};

