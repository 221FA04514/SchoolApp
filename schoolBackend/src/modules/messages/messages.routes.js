const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");

const {
  studentSendMessage,
  teacherSendMessage,
  getMessages,
  getTeachersForStudent, // 👈 MUST BE IMPORTED
} = require("./messages.controller");

// 👇 THIS ROUTE MUST EXIST
router.get("/teachers", authMiddleware, getTeachersForStudent);

router.get("/", authMiddleware, getMessages);
router.post("/student", authMiddleware, studentSendMessage);
router.post("/teacher", authMiddleware, teacherSendMessage);

module.exports = router;
