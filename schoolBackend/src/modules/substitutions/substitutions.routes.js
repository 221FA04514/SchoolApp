const express = require("express");
const router = express.Router();
const controller = require("./substitutions.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const adminOnly = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ success: false, message: "Admin access only" });
    }
    next();
};

// Teacher-accessible route — must be placed BEFORE the adminOnly middleware
router.get("/my-today", authMiddleware, controller.getMyTodaySubstitution);

router.use(authMiddleware, adminOnly);

router.post("/absent", controller.markAbsent);
router.get("/suggestions", controller.getSuggestions);
router.get("/teacher-timetable", controller.getTeacherTimetable);
router.post("/assign", controller.assign);
router.get("/list", controller.listDaySubstitutions);
router.delete("/:id", controller.deleteSubstitution);

module.exports = router;

