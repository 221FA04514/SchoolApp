const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const { addPerformance, getMyPerformance } = require("./performance.controller");

router.post("/", authMiddleware, addPerformance);
router.get("/student/my", authMiddleware, getMyPerformance);

module.exports = router;
