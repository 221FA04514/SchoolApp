const pool = require('../src/config/db');

async function checkExamsSchema() {
  try {
    const [cols] = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'exams' AND column_name = 'is_published'");
    console.log(cols);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkExamsSchema();
