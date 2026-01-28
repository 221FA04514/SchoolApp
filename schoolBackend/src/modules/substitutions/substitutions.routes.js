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

router.use(authMiddleware, adminOnly);

router.post("/absent", controller.markAbsent);
router.get("/suggestions", controller.getSuggestions);
router.post("/assign", controller.assign);
router.get("/list", controller.listDaySubstitutions);

module.exports = router;
