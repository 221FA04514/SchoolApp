const express = require("express");
const router = express.Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
    createExam,
    listAvailableExams,
    getQuestions,
    startAttempt,
    submitAttempt,
    getAttemptDetails,
} = require("./online_exams.controller");

router.post("/create", authMiddleware, createExam);
router.get("/list", authMiddleware, listAvailableExams);
router.get("/questions/:examId", authMiddleware, getQuestions);
router.post("/attempt", authMiddleware, startAttempt);
router.get("/attempt/:examId", authMiddleware, getAttemptDetails);
router.post("/submit", authMiddleware, submitAttempt);

router.get("/teacher/list", authMiddleware, require("./online_exams.controller").getTeacherExams);
router.delete("/teacher/:examId", authMiddleware, require("./online_exams.controller").deleteExam);

module.exports = router;
