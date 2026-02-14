const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const { getMyFees, recordPayment } = require("./fees.controller");

router.get("/my", authMiddleware, getMyFees);
router.post("/pay", authMiddleware, recordPayment);
router.post("/pay-online", authMiddleware, require("./fees.controller").payOnline);

module.exports = router;
