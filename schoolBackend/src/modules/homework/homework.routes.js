const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  createHomework,
  getMyHomework,
  getHomeworkForStudent,
  submitHomework,
  getSubmissions,
  gradeHomework,
} = require("./homework.controller");

/* ---------- TEACHER ---------- */
router.post("/", authMiddleware, createHomework);
router.get("/teacher", authMiddleware, getMyHomework);
router.get("/submissions/:homework_id", authMiddleware, getSubmissions);
router.post("/grade", authMiddleware, gradeHomework);

/* ---------- STUDENT ---------- */
router.get("/student", authMiddleware, getHomeworkForStudent);
router.post("/submit", authMiddleware, submitHomework);
router.post("/status", authMiddleware, require("./homework.controller").markHomeworkStatus);

module.exports = router;
