const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const {
  createExam,
  uploadMarks,
  getMyResults,
  togglePublish,
  getSections,
  getSectionStudents,
  bulkUploadMarks,
} = require("./results.controller");

router.post("/exam", authMiddleware, createExam);
router.post("/marks", authMiddleware, uploadMarks);
router.post("/bulk-marks", authMiddleware, bulkUploadMarks);
router.post("/toggle-publish", authMiddleware, togglePublish);
router.get("/sections", authMiddleware, getSections);
router.get("/students/:sectionId", authMiddleware, getSectionStudents);
router.get("/list", authMiddleware, (req, res, next) => {
  const { listExams } = require("./results.controller");
  listExams(req, res, next);
});
router.get("/my", authMiddleware, getMyResults);

router.get("/exam-marks/:examId/:sectionId", authMiddleware, (req, res, next) => {
  const { getExamMarks } = require("./results.controller");
  getExamMarks(req, res, next);
});

module.exports = router;
