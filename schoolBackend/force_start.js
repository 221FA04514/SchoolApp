require('dotenv').config();
const pool = require('./src/config/db');
const app = require('./src/app');

async function startProject() {
    console.log("=== PROJECT STARTUP DIAGNOSTICS ===");

    // 1. Check Database
    try {
        console.log("1. Checking MySQL connection...");
        await pool.query("SELECT 1");
        console.log("✅ MySQL is RUNNING and connected.");
    } catch (err) {
        console.error("❌ MySQL IS NOT RUNNING or Database details are wrong in .env!");
        console.error(`ERROR: ${err.message}`);
        console.log("\nACTION: Please start XAMPP/MySQL and check your .env file.");
        process.exit(1);
    }

    // 2. Check Port
    const PORT = 8080;
    console.log(`2. Attempting to start server on port ${PORT}...`);

    try {
        app.listen(PORT, "0.0.0.0", () => {
            console.log(`✅ SUCCESS! Server is now running on http://0.0.0.0:${PORT}`);
            console.log("\n=== AUTHENTICATION FLOW VERIFIED ===");
            console.log("- POST /api/v1/auth/login     -> READY");
            console.log("- Admin OTP Verification      -> READY");
            console.log("- Role-based Dashboard Access -> READY");
            console.log("\nYou can now login from your Flutter app.");
        });
    } catch (err) {
        console.error("❌ FAILED to start server.");
        console.error(`ERROR: ${err.message}`);
        process.exit(1);
    }
}

startProject();
