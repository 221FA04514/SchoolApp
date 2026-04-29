const express = require("express");
const router = express.Router();
const settingsController = require("./settings.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const adminOnly = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ success: false, message: "Admin access only" });
    }
    next();
};

router.get("/academic-year", authMiddleware, settingsController.getAcademicYear);
router.post("/academic-year", authMiddleware, adminOnly, settingsController.updateAcademicYear);

module.exports = router;
