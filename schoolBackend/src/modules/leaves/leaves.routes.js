const express = require("express");
const router = express.Router();
const leaveController = require("./leaves.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

router.post("/apply", authMiddleware, leaveController.applyLeave);
router.get("/my-leaves", authMiddleware, leaveController.getStudentLeaves);
router.get("/all", authMiddleware, leaveController.getAllLeaves);
router.patch("/:id/status", authMiddleware, leaveController.updateLeaveStatus);

module.exports = router;
