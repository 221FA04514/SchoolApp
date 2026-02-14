const pool = require('./src/config/db');

async function getIds() {
    try {
        const [users] = await pool.query("SELECT id FROM users LIMIT 1");
        const [sections] = await pool.query("SELECT id FROM sections LIMIT 1");
        console.log("Valid User ID:", users[0]?.id);
        console.log("Valid Section ID:", sections[0]?.id);
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

getIds();
