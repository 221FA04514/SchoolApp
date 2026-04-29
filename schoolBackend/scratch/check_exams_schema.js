const pool = require('../src/config/db');
async function check() {
  try {
    const [cols] = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'exams'");
    console.log('Columns:', JSON.stringify(cols, null, 2));
    process.exit(0);
  } catch(e) {
    console.error(e);
    process.exit(1);
  }
}
check();
