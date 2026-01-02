const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  markStudentAttendance,
  getMyAttendance,
  getMyAttendanceSummary,
  getMyAttendanceCalendar,
} = require("./attendance.controller");

router.post("/mark", authMiddleware, markStudentAttendance);
router.get("/my", authMiddleware, getMyAttendance);
router.get("/summary", authMiddleware, getMyAttendanceSummary);
router.get("/calendar", authMiddleware, getMyAttendanceCalendar);


module.exports = router;
