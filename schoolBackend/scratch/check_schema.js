const pool = require('../src/config/db');

async function checkSchema() {
  try {
    console.log("--- online_exams columns ---");
    const [oeCols] = await pool.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'online_exams'");
    console.log(oeCols.map(c => c.column_name));

    console.log("\n--- exams columns ---");
    const [exCols] = await pool.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'exams'");
    console.log(exCols.map(c => c.column_name));

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkSchema();
