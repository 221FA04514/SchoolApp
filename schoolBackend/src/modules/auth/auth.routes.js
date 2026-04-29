const router = require("express").Router();
const { login, verifyOtp, resendOtp, getProfile } = require("./auth.controller");
const authMiddleware = require("../../middlewares/auth.middleware");

const { uploadToS3 } = require("../../utils/s3_storage");

router.post("/login", login);
router.post("/verify-otp", verifyOtp);
router.post("/resend-otp", resendOtp);
router.get("/profile", authMiddleware, getProfile);

// Profile Pic Upload
router.post("/upload-avatar", authMiddleware, uploadToS3('profile_pics').single('avatar'), (req, res, next) => {
    const { uploadAvatar } = require("./auth.controller");
    uploadAvatar(req, res, next);
});

module.exports = router;
