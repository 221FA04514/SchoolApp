const { success, error } = require("../../utils/response");
const {
  getStudentInfo,
  getLatestAnnouncements,
  fetchTeacherDashboard,
} = require("./dashboard.service");
const attendanceService = require("../attendance/attendance.service");
const resultsService = require("../results/results.service");

exports.getTeacherDashboard = async (req, res, next) => {
  try {
    const { role, userId } = req.user;

    if (role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const data = await fetchTeacherDashboard(userId);
    return success(res, data, "Teacher dashboard fetched");
  } catch (err) {
    next(err);
  }
};

exports.getStudentDashboard = async (req, res, next) => {
  try {
    const { userId, role } = req.user;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    const studentInfo = await getStudentInfo(userId);
    const announcements = await getLatestAnnouncements();

    let attendance = { present: 0, absent: 0, percentage: 0 };
    let recentResults = [];

    if (studentInfo) {
      attendance = await attendanceService.getOverallAttendanceSummary(studentInfo.id);
      recentResults = await resultsService.getStudentResults(studentInfo.id);
    }

    return success(res, {
      student: studentInfo,
      announcements,
      attendance,
      recentExam: recentResults.length > 0 ? recentResults[0] : null,
      fees: {
        total: 0,
        paid: 0,
        due: 0,
      },
    }, "Dashboard data fetched");

  } catch (err) {
    next(err);
  }
};
