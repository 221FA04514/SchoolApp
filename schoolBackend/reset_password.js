
const pool = require('./src/config/db');
const bcrypt = require('bcrypt');

async function reset() {
    try {
        const hash = await bcrypt.hash("123456", 10);
        await pool.query("UPDATE users SET password = ? WHERE email = 'student@test.com'", [hash]);
        console.log("Password reset for student@test.com to 123456");
        process.exit();
    } catch (err) {
        if (err.code === 'MODULE_NOT_FOUND') {
            try {
                const bcrypt2 = require('bcrypt');
                const hash = await bcrypt2.hash("123456", 10);
                await pool.query("UPDATE users SET password = ? WHERE email = 'student@test.com'", [hash]);
                console.log("Password reset for student@test.com to 123456");
                process.exit();
            } catch (e) {
                console.error(e);
                process.exit(1);
            }
        } else {
            console.error(err);
            process.exit(1);
        }
    }
}

reset();
