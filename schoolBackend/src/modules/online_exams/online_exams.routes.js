const express = require("express");
const router = express.Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
    createExam,
    listAvailableExams,
    getQuestions,
    startAttempt,
    submitAttempt,
} = require("./online_exams.controller");

router.post("/create", authMiddleware, createExam);
router.get("/list", authMiddleware, listAvailableExams);
router.get("/questions/:examId", authMiddleware, getQuestions);
router.post("/attempt", authMiddleware, startAttempt);
router.post("/submit", authMiddleware, submitAttempt);

module.exports = router;
