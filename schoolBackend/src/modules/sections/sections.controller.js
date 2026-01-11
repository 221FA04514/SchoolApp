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

    if (role === "admin") {
      query = `SELECT id, name FROM sections ORDER BY name`;
      params = [];
    } else if (role === "teacher") {
      query = `SELECT DISTINCT s.id, s.name 
               FROM sections s
               JOIN timetable t ON s.id = t.section_id
               JOIN teachers tr ON t.teacher_name = tr.name
               WHERE tr.user_id = ?
               ORDER BY s.name`;
      params = [userId];
    } else {
      return error(res, "Access denied", 403);
    }

    const [rows] = await pool.query(query, params);

    return success(res, rows, "Sections fetched");
  } catch (err) {
    next(err);
  }
};
