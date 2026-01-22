const express = require("express");
const router = express.Router();
const quizController = require("./quizzes.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

router.post("/", authMiddleware, quizController.createQuiz);
router.get("/", authMiddleware, quizController.getQuizzes);
router.get("/:id", authMiddleware, quizController.getQuizDetails);
router.post("/submit", authMiddleware, quizController.submitAttempt);

module.exports = router;
