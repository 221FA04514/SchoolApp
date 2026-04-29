const mysql = require('mysql2/promise');
require('dotenv').config({ path: 'c:/Users/Admin/Desktop/school1/SchoolApp/schoolBackend/.env' });

async function run() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        port: process.env.DB_PORT,
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        console.log("Resetting all fee payments for testing...");
        await connection.query("DELETE FROM fee_payments WHERE payment_mode IN ('UPI', 'Card', 'Net Banking', 'Online')");
        
        console.log("Ensuring students have a 50k total fee...");
        await connection.query("UPDATE fees SET total_amount = 50000");
        
        console.log("Done. Data reset.");
    } catch (err) {
        console.error(err);
    } finally {
        await connection.end();
    }
}

run();
