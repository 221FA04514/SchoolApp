const pool = require('../src/config/db');

async function updateSchema() {
  try {
    console.log("Updating homework table...");
    await pool.query("ALTER TABLE homework ADD COLUMN IF NOT EXISTS needs_submission BOOLEAN DEFAULT TRUE");
    console.log("Schema updated successfully");
    process.exit(0);
  } catch (err) {
    console.error("Error updating schema:", err);
    process.exit(1);
  }
}

updateSchema();
