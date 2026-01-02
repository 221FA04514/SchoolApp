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

    const user = await findUserByEmail(email);
    if (!user) {
      return error(res, "Invalid credentials", 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return error(res, "Invalid credentials", 401);
    }

    const token = generateToken({
      userId: user.id,
      role: user.role,
    });

    return success(res, {
      token,
      role: user.role,
    }, "Login successful");

  } catch (err) {
    next(err);
  }
};
