const pool = require('../src/config/db');
async function check() {
  try {
    const [rows] = await pool.query("SELECT id, user_id FROM students WHERE id = 4");
    console.log('Student Info:', JSON.stringify(rows[0], null, 2));
    process.exit(0);
  } catch(e) {
    console.error(e);
    process.exit(1);
  }
}
check();
