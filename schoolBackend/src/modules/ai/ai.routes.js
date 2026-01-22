const express = require("express");
const router = express.Router();
const aiController = require("./ai.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

router.post("/homework-helper", authMiddleware, aiController.homeworkHelper);
router.post("/solve-doubt", authMiddleware, aiController.solveDoubt);
router.get("/study-plan", authMiddleware, aiController.getStudyPlan);

module.exports = router;
