const { success, error } = require("../../utils/response");
const {
  markAttendance,
  getStudentAttendance,
  getAttendanceSummary,
  getAttendanceCalendarMap,
  getStudentsForTeacher,
  upsertAttendance,
} = require("./attendance.service");

/**
 * Teacher marks attendance (single student)
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
 * Teacher: get students list for attendance
 */
exports.getStudentsForAttendance = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const students = await getStudentsForTeacher();
    return success(res, students, "Students fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: submit attendance (bulk) — FIXED TIMEOUT
 */
exports.submitAttendance = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { date, attendance } = req.body;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    if (!date || !Array.isArray(attendance)) {
      return error(res, "Invalid data", 400);
    }

    await Promise.all(
      attendance.map((item) =>
        upsertAttendance({
          student_id: item.student_id,
          date,
          status: item.status,
          marked_by: userId,
        })
      )
    );

    return success(res, null, "Attendance submitted successfully");
  } catch (err) {
    next(err);
  }
};

/**
 * Student: view attendance
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
 * Student: attendance calendar
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
 * Student: attendance summary
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
