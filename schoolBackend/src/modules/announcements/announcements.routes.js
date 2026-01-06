const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  listAnnouncements,
  getAnnouncement,
  createAnnouncement,
  getTeacherAnnouncements,
} = require("./announcements.controller");

/* TEACHER — MUST COME FIRST */
router.get("/teacher", authMiddleware, getTeacherAnnouncements);

/* STUDENT / COMMON */
router.get("/:id", authMiddleware, getAnnouncement);
router.get("/", authMiddleware, listAnnouncements);
router.post("/", authMiddleware, createAnnouncement);

module.exports = router;
