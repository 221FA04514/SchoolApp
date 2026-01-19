const router = require("express").Router();
const { login, verifyOtp, resendOtp } = require("./auth.controller");

router.post("/login", login);
router.post("/verify-otp", verifyOtp);
router.post("/resend-otp", resendOtp);

module.exports = router;
