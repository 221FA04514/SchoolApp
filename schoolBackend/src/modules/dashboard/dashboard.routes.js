const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  getStudentDashboard,
  getTeacherDashboard,
} = require("./dashboard.controller");

router.get("/student", authMiddleware, getStudentDashboard);
router.get("/teacher", authMiddleware, getTeacherDashboard);

module.exports = router;
