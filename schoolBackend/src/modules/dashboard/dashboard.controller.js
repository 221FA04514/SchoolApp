const { success, error } = require("../../utils/response");
const {
  getStudentInfo,
  getLatestAnnouncements,
  fetchTeacherDashboard,
} = require("./dashboard.service");

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

    return success(res, {
      student: studentInfo,
      announcements,
      attendance: {
        present: 0,
        absent: 0,
        percentage: 0,
      },
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
