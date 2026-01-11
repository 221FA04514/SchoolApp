const pool = require("../../config/db");

exports.findUserByEmail = async (email) => {
  const [rows] = await pool.query(
    `SELECT u.*, s.section_id 
     FROM users u 
     LEFT JOIN students s ON u.id = s.user_id 
     WHERE u.email = ? AND (u.status = 1 OR u.status = true)`,
    [email]
  );
  return rows[0];
};
