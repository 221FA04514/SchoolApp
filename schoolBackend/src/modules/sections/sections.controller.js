const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

/**
 * Teacher: get sections
 */
exports.getSections = async (req, res, next) => {
  try {
    const { userId, role } = req.user;

    let query;
    let params;

    if (role === "admin" || role === "teacher") {
      query = `SELECT id, name, class, section FROM sections ORDER BY name`;
      params = [];
    } else {
      return error(res, "Access denied", 403);
    }

    const [rows] = await pool.query(query, params);

    return success(res, rows, "Sections fetched");
  } catch (err) {
    next(err);
  }
};
