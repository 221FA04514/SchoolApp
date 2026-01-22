const express = require("express");
const router = express.Router();
const notifController = require("./notifications.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

router.get("/", authMiddleware, notifController.getNotifications);
router.patch("/:id/read", authMiddleware, notifController.markRead);

module.exports = router;
