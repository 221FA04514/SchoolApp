const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Configure Multer
const { uploadToS3 } = require("../../utils/s3_storage");

const upload = uploadToS3("homework");


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
router.delete("/:id", authMiddleware, require("./homework.controller").deleteHomework);

/* ---------- STUDENT ---------- */
router.get("/student", authMiddleware, getHomeworkForStudent);
router.post("/submit", authMiddleware, upload.single("file"), submitHomework);
router.post("/status", authMiddleware, require("./homework.controller").markHomeworkStatus);

module.exports = router;
