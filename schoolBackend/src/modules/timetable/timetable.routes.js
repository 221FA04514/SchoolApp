const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");

const {
  saveTimetable,
  getSectionTimetable,
  getMyTimetable,
  removeSlot,
} = require("./timetable.controller");

/* HEALTH CHECK */
router.get("/ping", (req, res) => {
  res.json({ success: true, message: "Timetable route alive" });
});

/* TEACHER / ADMIN */
router.post("/", authMiddleware, saveTimetable);
router.get("/section", authMiddleware, getSectionTimetable);
router.delete("/:id", authMiddleware, removeSlot);

/* STUDENT */
router.get("/my", authMiddleware, getMyTimetable);

module.exports = router;
