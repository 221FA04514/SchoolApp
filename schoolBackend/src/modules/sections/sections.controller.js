const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

/**
 * Teacher: get sections
 */
exports.getSections = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const [rows] = await pool.query(
      "SELECT id, name FROM sections ORDER BY name"
    );

    return success(res, rows, "Sections fetched");
  } catch (err) {
    next(err);
  }
};
