const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  listAnnouncements,
  getAnnouncement,
  createAnnouncement,
  getTeacherAnnouncements,
  removeAnnouncement,
  dismissAnnouncementForUser,
} = require("./announcements.controller");

/* TEACHER — MUST COME FIRST */
router.get("/teacher", authMiddleware, getTeacherAnnouncements);
router.delete("/:id", authMiddleware, removeAnnouncement);

/* STUDENT: dismiss (hide) an announcement from their view */
router.post("/:id/dismiss", authMiddleware, dismissAnnouncementForUser);

/* STUDENT / COMMON */
router.get("/:id", authMiddleware, getAnnouncement);
router.get("/", authMiddleware, listAnnouncements);
router.post("/", authMiddleware, createAnnouncement);

module.exports = router;
