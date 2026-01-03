const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");

const {
  markStudentAttendance,
  getMyAttendance,
  getMyAttendanceSummary,
  getMyAttendanceCalendar,
  getStudentsForAttendance,
  submitAttendance,
} = require("./attendance.controller");

router.get("/ping", (req, res) => {
  res.json({ success: true, message: "Attendance route alive" });
});

/* ========== TEACHER ROUTES ========== */
router.get("/students", authMiddleware, getStudentsForAttendance);
router.post("/submit", authMiddleware, submitAttendance);
router.post("/mark", authMiddleware, markStudentAttendance);

/* ========== STUDENT ROUTES ========== */
router.get("/my", authMiddleware, getMyAttendance);
router.get("/summary", authMiddleware, getMyAttendanceSummary);
router.get("/calendar", authMiddleware, getMyAttendanceCalendar);

module.exports = router;
