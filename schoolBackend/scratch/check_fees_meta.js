const pool = require('../src/config/db');

async function check() {
    try {
        const [columns] = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'fees_structure'");
        console.log("Columns:", columns);

        const [constraints] = await pool.query(`
            SELECT conname, pg_get_constraintdef(c.oid) 
            FROM pg_constraint c 
            JOIN pg_namespace n ON n.oid = c.connamespace 
            WHERE conrelid = 'fees_structure'::regclass
        `);
        console.log("Constraints:", constraints);
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

check();
