const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  listAnnouncements,
  getAnnouncement,
  createAnnouncement,
} = require("./announcements.controller");

router.get("/", authMiddleware, listAnnouncements);
router.get("/:id", authMiddleware, getAnnouncement);
router.post("/", authMiddleware, createAnnouncement);


module.exports = router;
