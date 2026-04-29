const pool = require('../src/config/db');

async function check() {
    try {
        const [constraints] = await pool.query(`
            SELECT conname, pg_get_constraintdef(c.oid) 
            FROM pg_constraint c 
            JOIN pg_namespace n ON n.oid = c.connamespace 
            WHERE conrelid = 'fees'::regclass
        `);
        console.log("Fees Constraints:", constraints);
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

check();
