require('dotenv').config({ path: '../.env' });
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT || 5432,
  ssl: {
    rejectUnauthorized: false
  }
});

async function clearAlerts() {
  try {
    console.log("Connecting to database...");
    
    await pool.query('TRUNCATE TABLE notification_receipts CASCADE;');
    console.log("Cleared notification_receipts");

    await pool.query('TRUNCATE TABLE mass_notifications CASCADE;');
    console.log("Cleared mass_notifications");

    await pool.query('TRUNCATE TABLE announcement_dismissals CASCADE;');
    console.log("Cleared announcement_dismissals");

    await pool.query('TRUNCATE TABLE announcements CASCADE;');
    console.log("Cleared announcements");

    console.log("All alerts successfully cleared!");
  } catch (error) {
    console.error("Error clearing alerts:", error);
  } finally {
    await pool.end();
  }
}

clearAlerts();
