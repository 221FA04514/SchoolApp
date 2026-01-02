const pool = require("../../config/db");

exports.findUserByEmail = async (email) => {
  const [rows] = await pool.query(
    "SELECT * FROM users WHERE email = ? AND status = true",
    [email]
  );
  return rows[0];
};
