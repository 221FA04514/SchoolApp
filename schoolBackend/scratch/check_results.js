const pool = require('../src/config/db');
async function check() {
  try {
    const [rows] = await pool.query("SELECT * FROM results LIMIT 1");
    console.log('Sample Result:', JSON.stringify(rows[0], null, 2));
    
    const [cols] = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'results'");
    console.log('Columns:', JSON.stringify(cols, null, 2));
    
    process.exit(0);
  } catch(e) {
    console.error(e);
    process.exit(1);
  }
}
check();
