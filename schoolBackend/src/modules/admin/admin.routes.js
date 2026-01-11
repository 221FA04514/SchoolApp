const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
    getTeachers,
    getStudents,
    getSections,
    createSection,
    removeSection,
    registerUser,
    updateUser,
    listPeriodSettings,
    savePeriodSetting,
    removePeriodSetting
} = require("./admin.controller");

const adminOnly = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ success: false, message: "Admin access only" });
    }
    next();
};

router.use(authMiddleware, adminOnly);

router.get("/teachers", getTeachers);
router.get("/students", getStudents);
router.get("/sections", getSections);
router.post("/sections", createSection);
router.delete("/sections/:id", removeSection);
router.post("/register", registerUser);
router.put("/users/:id", updateUser);

// Period Settings
router.get("/period-settings", listPeriodSettings);
router.post("/period-settings", savePeriodSetting);
router.delete("/period-settings/:id", removePeriodSetting);

module.exports = router;
