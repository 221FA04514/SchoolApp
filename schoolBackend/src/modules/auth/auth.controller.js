
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
      // 2. SKIP Twilio Verification for default OTP flow
      // const verification = await sms.startVerification(user.admin_phone);

      // if (!verification.success) {
      //   return error(res, `Verification failed: ${verification.error || 'Check Twilio setup'}`, 500);
      // }

      return success(res, {
        requiresOtp: true,
        userId: user.id,
        phone: "HIDDEN",
      }, "Password verified. Enter default OTP.");
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

    // BYPASS if code is "00000"
    console.log(`[DEBUG] Verifying OTP. UserId: ${userId}, Code: ${code}`);

    if (code !== "00000") {
      // 1. Get Phone Number for User
      const phone = await authService.getAdminPhone(userId);
      if (!phone) return error(res, "Admin phone number not found", 404);

      // 2. Check Verification with Twilio
      const result = await sms.checkVerification(phone, code);
      if (!result.success || result.status !== 'approved') {
        return error(res, result.error || "Invalid or expired OTP", 401);
      }
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

    const verification = await sms.startVerification(phone);
    if (!verification.success) {
      return error(res, `Failed to resend: ${verification.error}`, 500);
    }

    return success(res, null, verification.simulated ? "Simulation Mode: Use 123456" : "OTP resent successfully");
  } catch (err) {
    next(err);
  }
};

exports.getProfile = async (req, res, next) => {
  try {
    const { userId, role } = req.user;
    const pool = require("../../config/db");

    let profileData = {};

    if (role === 'student') {
      const [rows] = await pool.query(`
        SELECT s.name, s.class as class_name, s.roll_number, sec.name as section_name,
               s.class as raw_class, s.section as raw_section,
               s.parent_name, s.phone, s.address
        FROM students s
        LEFT JOIN sections sec ON s.section_id = sec.id
        WHERE s.user_id = ?
      `, [userId]);
      profileData = rows[0] || {};
    } else if (role === 'teacher') {
      const [rows] = await pool.query(`
        SELECT name, subject, phone FROM teachers WHERE user_id = ?
      `, [userId]);
      profileData = rows[0] || {};
    } else {
      profileData = { name: 'Administrator', role: 'admin' };
    }

    // Add profile picture from users table
    const [userRows] = await pool.query("SELECT profile_picture FROM users WHERE id = ?", [userId]);
    profileData.profile_picture = userRows[0]?.profile_picture;

    return success(res, profileData, "Profile fetched");
  } catch (err) {
    next(err);
  }
};

exports.uploadAvatar = async (req, res, next) => {
    try {
        const { userId } = req.user;
        const pool = require("../../config/db");

        if (!req.file) {
            return error(res, "No image uploaded", 400);
        }

        let imageUrl = req.file.location; // S3 storage returns location
        
        if (!imageUrl) {
            // Local storage fallback
            const protocol = req.protocol;
            const host = req.get('host');
            const folder = req.file.destination.split(require('path').sep).pop(); // Get 'profile_pics'
            imageUrl = `${protocol}://${host}/uploads/${folder}/${req.file.filename}`;
        }

        await pool.query("UPDATE users SET profile_picture = ? WHERE id = ?", [imageUrl, userId]);

        return success(res, { imageUrl }, "Profile picture updated");
    } catch (err) {
        next(err);
    }
};
