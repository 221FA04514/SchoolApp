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
 * Teacher: get students (section optional)
 */
exports.getStudentsForAttendance = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const { section_id } = req.query;

    const students = await getStudentsForTeacher(section_id || null);
    return success(res, students, "Students fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: mark attendance (single student)
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

    const today = new Date().toISOString().split("T")[0];
    if (date > today) {
      return error(res, "Cannot mark attendance for future dates", 400);
    }

    await markAttendance({
      student_id,
      date,
      status,
      marked_by: userId,
    });

    return success(res, null, "Attendance marked");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: submit attendance (bulk)
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

    const today = new Date().toISOString().split("T")[0];
    if (date > today) {
      return error(res, "Cannot mark attendance for future dates", 400);
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

    return success(res, null, "Attendance submitted");
  } catch (err) {
    next(err);
  }
};

/**
 * Student: attendance APIs (UNCHANGED)
 */
exports.getMyAttendance = async (req, res, next) => {
  const { role, userId } = req.user;
  const { month, year } = req.query;

  if (role !== "student") return error(res, "Access denied", 403);

  const data = await getStudentAttendance(userId, month, year);
  return success(res, data, "Attendance fetched");
};

exports.getMyAttendanceSummary = async (req, res, next) => {
  const { role, userId } = req.user;
  const { month, year } = req.query;

  if (role !== "student") return error(res, "Access denied", 403);

  const data = await getAttendanceSummary(userId, month, year);
  return success(res, data, "Summary fetched");
};

exports.getMyAttendanceCalendar = async (req, res, next) => {
  const { role, userId } = req.user;
  const { month, year } = req.query;

  if (role !== "student") return error(res, "Access denied", 403);

  const data = await getAttendanceCalendarMap(userId, month, year);
  return success(res, data, "Calendar fetched");
};
