/* eslint-disable no-console */
const pool = require('../src/config/db');

async function testConnection() {
  console.log('Testing connection to PostgreSQL...');
  try {
    // 1. Basic Check
    const [rows] = await pool.query('SELECT current_database(), now()');
    console.log('Successfully connected to DB:', rows[0].current_database);
    console.log('Server time:', rows[0].now);
    
    // 2. Data Check (Verify if our migration script actually worked)
    const [userCount] = await pool.query('SELECT COUNT(*) FROM "users"');
    console.log('Total users in database:', userCount[0].count);
    
    // 3. Serial Sequence Check
    // We want to avoid 'duplicate key' errors on new inserts
    console.log('Checking table "users" sequence...');
    const [seqCheck] = await pool.query('SELECT pg_get_serial_sequence(\'"users"\', \'id\')');
    console.log('Sequence name:', seqCheck[0].pg_get_serial_sequence);
    
    console.log('\nSUCCESS: Backend can communicate with PostgreSQL perfectly.');
    process.exit(0);
  } catch (err) {
    console.error('\nERROR: Connection failed.');
    console.error('Reason:', err.message);
    console.error('Check your .env file and ensure AWS RDS allows connections from this IP.');
    process.exit(1);
  }
}

testConnection();
