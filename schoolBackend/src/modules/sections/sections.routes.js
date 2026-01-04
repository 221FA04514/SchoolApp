const router = require("express").Router();
const authMiddleware = require("../../middlewares/auth.middleware");
const { getSections } = require("./sections.controller");

router.get("/", authMiddleware, getSections);

module.exports = router;
