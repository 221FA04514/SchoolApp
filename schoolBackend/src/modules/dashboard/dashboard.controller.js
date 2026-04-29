const { success, error } = require("../../utils/response");
const {
  getStudentInfo,
  getLatestAnnouncements,
  fetchTeacherDashboard,
} = require("./dashboard.service");
const attendanceService = require("../attendance/attendance.service");
const resultsService = require("../results/results.service");
const homeworkService = require("../homework/homework.service");
const pool = require("../../config/db");

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
    console.log(`[DEBUG] Dashboard Fetch - UserID: ${userId}, Role: ${role}`);
    console.log(`[DEBUG] Student Info Found:`, studentInfo);
    const announcements = await getLatestAnnouncements();

    let attendance = { present: 0, absent: 0, percentage: 0 };
    let recentResults = [];

    if (studentInfo) {
      attendance = await attendanceService.getOverallAttendanceSummary(userId);
      recentResults = await resultsService.getStudentResults(studentInfo.id);
      
      const pendingHw = await homeworkService.getPendingHomeworkCount(studentInfo.section_id || 0, userId);
      const hwCompletion = await homeworkService.getHomeworkCompletion(studentInfo.section_id || 0, userId);
      
      const [[leaves]] = await pool.query(
        "SELECT COUNT(*) as count FROM leaves WHERE student_id = ? AND status = 'approved'",
        [userId]
      );
      
      const [[recentLeave]] = await pool.query(
        "SELECT status FROM leaves WHERE student_id = ? ORDER BY applied_at DESC LIMIT 1",
        [userId]
      );

      const stats = {
        pendingHomework: pendingHw || 0,
        homeworkCompletionPercentage: hwCompletion || 0,
        leavePercentage: 0, 
        approvedLeaves: leaves.count,
        recentLeaveStatus: recentLeave ? recentLeave.status : 'None'
      };

      console.log(`[DEBUG] Collected Stats for User ${userId}:`, stats);
      // Removed duplicate results fetch

      return success(res, {
        student: studentInfo,
        announcements,
        attendance,
        recentExam: recentResults.length > 0 ? recentResults[0] : null,
        stats: stats,
        fees: {
          total: 0,
          paid: 0,
          due: 0,
        },
      }, "Dashboard data fetched");
    }

  } catch (err) {
    next(err);
  }
};
