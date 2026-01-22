const express = require("express");
const router = express.Router();
const aiController = require("./ai.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

router.post("/homework-helper", authMiddleware, aiController.homeworkHelper);
router.post("/solve-doubt", authMiddleware, aiController.solveDoubt);
router.get("/study-plan", authMiddleware, aiController.getStudyPlan);
router.get("/history", authMiddleware, aiController.getHistory);
router.delete("/history/:id", authMiddleware, aiController.deleteHistoryItem);

// Teacher-specific AI routes
router.post("/teacher/homework-gen", authMiddleware, aiController.generateHomework);
router.post("/teacher/announcement-fix", authMiddleware, aiController.refineAnnouncement);
router.get("/teacher/insights/:studentId", authMiddleware, aiController.getStudentInsights);
router.get("/teacher/insights-detail", authMiddleware, aiController.getInsightDetails);

module.exports = router;
