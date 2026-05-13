const pool = require('../src/config/db');

async function checkData() {
  try {
    console.log("--- Homework Table ---");
    const [hwRows] = await pool.query("SELECT * FROM homework LIMIT 5");
    console.log(hwRows);

    console.log("\n--- Students Table ---");
    const [stdRows] = await pool.query("SELECT * FROM students LIMIT 5");
    console.log(stdRows);

    console.log("\n--- Exams Table (is_published status) ---");
    const [examRows] = await pool.query("SELECT id, name, is_published FROM exams LIMIT 5");
    console.log(examRows);

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

checkData();
