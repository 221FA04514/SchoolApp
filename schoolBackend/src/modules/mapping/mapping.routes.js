const express = require("express");
const router = express.Router();
const controller = require("./mapping.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const adminOnly = (req, res, next) => {
    if (req.user.role !== "admin") {
        return res.status(403).json({ success: false, message: "Admin access only" });
    }
    next();
};

// All routes are protected and for admin only
router.use(authMiddleware, adminOnly);

router.get("/", controller.list);
router.post("/", controller.create);
router.delete("/:id", controller.remove);

module.exports = router;
