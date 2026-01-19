const pool = require("../../config/db");

exports.findUserByEmail = async (email) => {
  const [rows] = await pool.query(
    `SELECT u.*, s.section_id, a.phone as admin_phone
     FROM users u 
     LEFT JOIN students s ON u.id = s.user_id 
     LEFT JOIN admins a ON u.id = a.user_id
     WHERE u.email = ? AND (u.status = 1 OR u.status = true)`,
    [email]
  );
  return rows[0];
};

exports.saveOtp = async (userId, code) => {
  // Expire in 5 minutes
  const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
  await pool.query(
    "INSERT INTO otp_codes (user_id, code, expires_at) VALUES (?, ?, ?)",
    [userId, code, expiresAt]
  );
};

exports.verifyOtp = async (userId, code) => {
  const [rows] = await pool.query(
    "SELECT id FROM otp_codes WHERE user_id = ? AND code = ? AND expires_at > NOW() ORDER BY created_at DESC LIMIT 1",
    [userId, code]
  );
  if (rows.length > 0) {
    // Delete OTP after successful verification
    await pool.query("DELETE FROM otp_codes WHERE id = ?", [rows[0].id]);
    return true;
  }
  return false;
};

exports.getAdminPhone = async (userId) => {
  const [rows] = await pool.query("SELECT phone FROM admins WHERE user_id = ?", [userId]);
  return rows.length > 0 ? rows[0].phone : null;
};
