
const bcrypt = require("bcrypt");
const { generateToken } = require("../../config/jwt");
const { success, error } = require("../../utils/response");
const authService = require("./auth.service");
const sms = require("../../utils/sms");

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    console.log(`Login attempt for: ${email}`);

    if (!email || !password) {
      return error(res, "Email and password required", 400);
    }

    console.log(`[DEBUG] DB_NAME: ${process.env.DB_NAME}, DB_USER: ${process.env.DB_USER}`);

    const trimmedEmail = email.trim().toLowerCase();
    const user = await authService.findUserByEmail(trimmedEmail);
    if (!user) {
      return error(res, "Invalid credentials", 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return error(res, "Invalid credentials", 401);
    }

    console.log(`[DEBUG] User found: ${user.email}, Phone: ${user.admin_phone}, Role: ${user.role}`);

    // Role-based custom logic
    if (user.role === "admin") {
      // 2. Start Twilio Verification
      await sms.startVerification(user.admin_phone);

      return success(res, {
        requiresOtp: true,
        userId: user.id,
        phone: user.admin_phone ? `******${user.admin_phone.slice(-4)}` : "unknown",
      }, "Password verified. OTP sent.");
    }

    const token = generateToken({
      userId: user.id,
      role: user.role,
      section_id: user.section_id,
    });

    return success(res, {
      token,
      role: user.role,
    }, "Login successful");

  } catch (err) {
    next(err);
  }
};

exports.verifyOtp = async (req, res, next) => {
  try {
    const { userId, code } = req.body;
    if (!userId || !code) {
      return error(res, "User ID and code required", 400);
    }

    // 1. Get Phone Number for User
    const phone = await authService.getAdminPhone(userId);
    if (!phone) return error(res, "Admin phone number not found", 404);

    // 2. Check Verification with Twilio
    const result = await sms.checkVerification(phone, code);
    if (!result.success || result.status !== 'approved') {
      return error(res, result.error || "Invalid or expired OTP", 401);
    }

    // Get user for token generation
    // Since we only have userId, we might need a findUserById or just use the userId directly
    // Let's assume we can get the role from the database if needed, or just trust the previous step
    // But for security, let's fetch user again or at least their role.
    const [userRows] = await require("../../config/db").query("SELECT id, role FROM users WHERE id = ?", [userId]);
    const user = userRows[0];

    const token = generateToken({
      userId: user.id,
      role: user.role,
    });

    return success(res, {
      token,
      role: user.role,
    }, "OTP verified. Login successful");

  } catch (err) {
    next(err);
  }
};

exports.resendOtp = async (req, res, next) => {
  try {
    const { userId } = req.body;
    if (!userId) return error(res, "User ID required", 400);

    // 2. Get Phone & Restart Verification
    const phone = await authService.getAdminPhone(userId);
    if (!phone) return error(res, "Admin phone number not found", 404);

    await sms.startVerification(phone);

    return success(res, null, "OTP resent successfully");
  } catch (err) {
    next(err);
  }
};
