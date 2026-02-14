const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Configure Multer
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = "uploads/";
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, "hw-" + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

const {
  createHomework,
  getMyHomework,
  getHomeworkForStudent,
  submitHomework,
  getSubmissions,
  gradeHomework,
} = require("./homework.controller");

/* ---------- TEACHER ---------- */
router.post("/", authMiddleware, createHomework);
router.get("/teacher", authMiddleware, getMyHomework);
router.get("/submissions/:homework_id", authMiddleware, getSubmissions);
router.post("/grade", authMiddleware, gradeHomework);

/* ---------- STUDENT ---------- */
router.get("/student", authMiddleware, getHomeworkForStudent);
router.post("/submit", authMiddleware, upload.single("file"), submitHomework);
router.post("/status", authMiddleware, require("./homework.controller").markHomeworkStatus);

module.exports = router;
