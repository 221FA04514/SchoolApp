const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  createHomework,
  getMyHomework,
  getHomeworkForStudent,
} = require("./homework.controller");

/* ---------- TEACHER ---------- */
router.post("/", authMiddleware, createHomework);
router.get("/teacher", authMiddleware, getMyHomework);

/* ---------- STUDENT ---------- */
router.get("/student", authMiddleware, getHomeworkForStudent);

module.exports = router;
