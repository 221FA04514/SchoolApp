const router = require("express").Router(); // ✅ THIS WAS MISSING
const authMiddleware = require("../../middlewares/auth.middleware");

const {
  studentSendMessage,
  teacherSendMessage,
  getMessages,
  getTeachersForStudent,
  getStudentsForTeacher,
} = require("./messages.controller");

// student → select teacher
router.get("/teachers", authMiddleware, getTeachersForStudent);

// teacher → list students who sent doubts
router.get("/students", authMiddleware, getStudentsForTeacher);

// common
router.get("/", authMiddleware, getMessages);
router.post("/student", authMiddleware, studentSendMessage);
router.post("/teacher", authMiddleware, teacherSendMessage);

module.exports = router;
