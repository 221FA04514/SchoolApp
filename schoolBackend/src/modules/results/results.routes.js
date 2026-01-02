const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  createExam,
  uploadMarks,
  getMyResults,
} = require("./results.controller");

router.post("/exam", authMiddleware, createExam);
router.post("/marks", authMiddleware, uploadMarks);
router.get("/my", authMiddleware, getMyResults);

module.exports = router;
