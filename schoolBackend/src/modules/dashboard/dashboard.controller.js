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

    if (!studentInfo) {
      return error(res, "Student profile not found", 404);
    }

    const attendance = await attendanceService.getOverallAttendanceSummary(userId);
    const recentResults = await resultsService.getStudentResults(studentInfo.id);
    const announcements = await getLatestAnnouncements(studentInfo.section_id);
    
    const pendingHw = await homeworkService.getPendingHomeworkCount(studentInfo.section_id || 0, userId);
    const hwCompletion = await homeworkService.getHomeworkCompletion(studentInfo.section_id || 0, userId);
    
    const [leavesRows] = await pool.query(
      "SELECT COUNT(*) as count FROM leaves WHERE student_id = ? AND status = 'approved'",
      [userId]
    );
    const leavesCount = parseInt(leavesRows[0]?.count || 0, 10);
    
    const [recentLeaveRows] = await pool.query(
      "SELECT status FROM leaves WHERE student_id = ? ORDER BY applied_at DESC LIMIT 1",
      [userId]
    );
    const recentLeaveStatus = recentLeaveRows[0]?.status || 'None';

    const stats = {
      pendingHomework: pendingHw || 0,
      homeworkCompletionPercentage: hwCompletion || 0,
      leavePercentage: 0, 
      approvedLeaves: leavesCount,
      recentLeaveStatus: recentLeaveStatus
    };

    console.log(`[DEBUG] Collected Stats for User ${userId}:`, stats);

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

  } catch (err) {
    next(err);
  }
};
