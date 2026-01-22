const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");

const {
  getStudentsForAttendance,
  submitAttendance,
  markStudentAttendance,
  getMyAttendance,
  getMyAttendanceSummary,
  getMyAttendanceCalendar,
  getHistory,
} = require("./attendance.controller");

router.get("/ping", (req, res) => {
  res.json({ success: true, message: "Attendance route alive" });
});

/* TEACHER */
router.get("/students", authMiddleware, getStudentsForAttendance);
router.post("/submit", authMiddleware, submitAttendance);
router.post("/mark", authMiddleware, markStudentAttendance);
router.get("/history", authMiddleware, getHistory);

/* STUDENT */
router.get("/my", authMiddleware, getMyAttendance);
router.get("/summary", authMiddleware, getMyAttendanceSummary);
router.get("/calendar", authMiddleware, getMyAttendanceCalendar);

module.exports = router;
