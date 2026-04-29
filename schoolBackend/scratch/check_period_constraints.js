const pool = require('../src/config/db');
async function check() {
  try {
    const [rows] = await pool.query(`
      SELECT 
        conname as constraint_name, 
        contype as constraint_type,
        pg_get_constraintdef(c.oid) as definition
      FROM pg_constraint c
      JOIN pg_namespace n ON n.oid = c.connamespace
      WHERE conrelid = 'period_settings'::regclass
    `);
    console.log(JSON.stringify(rows, null, 2));
    process.exit(0);
  } catch(e) {
    console.error(e);
    process.exit(1);
  }
}
check();
