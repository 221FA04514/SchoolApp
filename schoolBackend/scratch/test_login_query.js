const pool = require('../src/config/db');

async function test() {
  try {
    console.log("Starting Query...");
    const [rows] = await pool.query(`
      SELECT u.id, u.email, u.role, s.section_id, a.phone as admin_phone
      FROM users u 
      LEFT JOIN students s ON u.id = s.user_id 
      LEFT JOIN admins a ON u.id = a.user_id
      WHERE u.email = $1 AND u.status = 1
    `, ['test@student.com']);
    console.log("Query Success:", rows);
    process.exit(0);
  } catch (err) {
    console.error("Query Failed:", err);
    process.exit(1);
  }
}

test();
