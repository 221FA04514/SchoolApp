
const bcrypt = require("bcrypt");
const { generateToken } = require("../../config/jwt");
const { success, error } = require("../../utils/response");
const { findUserByEmail } = require("./auth.service");

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return error(res, "Email and password required", 400);
    }

    const trimmedEmail = email.trim().toLowerCase();
    console.log(`[Login Attempt] Email: ${trimmedEmail}`);

    const user = await findUserByEmail(trimmedEmail);
    if (!user) {
      console.log(`[Login Failed] User not found: ${trimmedEmail}`);
      return error(res, "Invalid credentials", 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      console.log(`[Login Failed] Password mismatch for: ${trimmedEmail}`);
      return error(res, "Invalid credentials", 401);
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
