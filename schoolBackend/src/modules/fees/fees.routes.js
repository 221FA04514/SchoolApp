const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const { getMyFees, recordPayment } = require("./fees.controller");
const structure = require("./fees_structure.controller");

router.get("/my", authMiddleware, getMyFees);
router.post("/pay", authMiddleware, recordPayment);
router.post("/pay-online", authMiddleware, require("./fees.controller").payOnline);

// Structure Management (Admin Only)
router.get("/structure", authMiddleware, structure.list);
router.post("/structure", authMiddleware, structure.save);
router.post("/individual", authMiddleware, structure.updateIndividual);

module.exports = router;
