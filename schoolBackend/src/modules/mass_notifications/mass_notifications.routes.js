const express = require("express");
const router = express.Router();
const controller = require("./mass_notifications.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const adminOnly = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ success: false, message: "Admin access only" });
    }
    next();
};

router.use(authMiddleware);

// User-accessible routes
router.get("/my", controller.getMyNotifications);
router.post("/mark-read/:id", controller.markRead);

// Admin-only routes
router.get("/", adminOnly, controller.listAll);
router.post("/send", adminOnly, controller.send);
router.delete("/:id", adminOnly, controller.delete);
router.post("/ai/formalize", adminOnly, controller.formalize);
router.post("/ai/translate", adminOnly, controller.translate);
router.get("/stats/:id", adminOnly, controller.getStats);

module.exports = router;
