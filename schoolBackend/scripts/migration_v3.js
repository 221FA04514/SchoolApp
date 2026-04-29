/**
 * Migration v3 — Run once to apply all schema fixes
 * node scripts/migration_v3.js
 */
const pool = require('../src/config/db');

async function migrate() {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        console.log('--- Starting Migration v3 ---');

        // 1. Add profile_picture column to users
        console.log('Step 1: Adding profile_picture to users...');
        const [userCols] = await connection.query(
            "SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='profile_picture'"
        );
        if (userCols.length === 0) {
            await connection.query("ALTER TABLE users ADD COLUMN profile_picture VARCHAR(500) DEFAULT NULL");
            console.log('  -> profile_picture column added.');
        } else {
            console.log('  -> Already exists, skipping.');
        }

        // 2. Ensure fees_structure table exists
        console.log('Step 2: Creating fees_structure table if not exists...');
        await connection.query(`
            CREATE TABLE IF NOT EXISTS fees_structure (
                id SERIAL PRIMARY KEY,
                section_id INTEGER NOT NULL UNIQUE REFERENCES sections(id) ON DELETE CASCADE,
                amount NUMERIC(10,2) NOT NULL DEFAULT 0,
                description VARCHAR(255),
                academic_year VARCHAR(20),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('  -> fees_structure ready.');

        // 3. Ensure fees table has description column
        console.log('Step 3: Checking fees.description column...');
        const [feeCols] = await connection.query(
            "SELECT column_name FROM information_schema.columns WHERE table_name='fees' AND column_name='description'"
        );
        if (feeCols.length === 0) {
            await connection.query("ALTER TABLE fees ADD COLUMN description VARCHAR(255)");
            console.log('  -> description column added to fees.');
        } else {
            console.log('  -> Already exists, skipping.');
        }

        // 4. Add UNIQUE constraint on fees.student_id if not present
        console.log('Step 4: Ensuring UNIQUE constraint on fees.student_id...');
        const [feeConstraints] = await connection.query(
            "SELECT constraint_name FROM information_schema.table_constraints WHERE table_name='fees' AND constraint_type='UNIQUE'"
        );
        const hasUnique = feeConstraints.some(c => c.constraint_name.includes('student_id'));
        if (!hasUnique) {
            try {
                await connection.query("ALTER TABLE fees ADD CONSTRAINT fees_student_id_unique UNIQUE (student_id)");
                console.log('  -> UNIQUE constraint added.');
            } catch (e) {
                console.log('  -> Constraint may already exist:', e.message);
            }
        } else {
            console.log('  -> Already exists, skipping.');
        }

        // 5. Add is_deleted column to notifications for soft delete
        console.log('Step 5: Adding is_deleted to notifications...');
        const [notifCols] = await connection.query(
            "SELECT column_name FROM information_schema.columns WHERE table_name='notifications' AND column_name='is_deleted'"
        );
        if (notifCols.length === 0) {
            await connection.query("ALTER TABLE notifications ADD COLUMN is_deleted SMALLINT DEFAULT 0");
            console.log('  -> is_deleted added to notifications.');
        } else {
            console.log('  -> Already exists, skipping.');
        }

        // 6. Create announcement_dismissals table for per-user dismissal
        console.log('Step 6: Creating announcement_dismissals table...');
        await connection.query(`
            CREATE TABLE IF NOT EXISTS announcement_dismissals (
                id SERIAL PRIMARY KEY,
                announcement_id INTEGER NOT NULL REFERENCES announcements(id) ON DELETE CASCADE,
                user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                dismissed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                CONSTRAINT unique_dismissal UNIQUE (announcement_id, user_id)
            )
        `);
        console.log('  -> announcement_dismissals ready.');

        // 7. Ensure school_settings table exists
        console.log('Step 7: Ensuring school_settings table...');
        await connection.query(`
            CREATE TABLE IF NOT EXISTS school_settings (
                id SERIAL PRIMARY KEY,
                key VARCHAR(100) NOT NULL UNIQUE,
                value TEXT,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log('  -> school_settings ready.');

        // 8. Add academic_year column to students if not present
        console.log('Step 8: Adding academic_year to students table...');
        const [stuCols] = await connection.query(
            "SELECT column_name FROM information_schema.columns WHERE table_name='students' AND column_name='academic_year'"
        );
        if (stuCols.length === 0) {
            await connection.query("ALTER TABLE students ADD COLUMN academic_year VARCHAR(20) DEFAULT '2025-26'");
            console.log('  -> academic_year added to students.');
        } else {
            console.log('  -> Already exists, skipping.');
        }

        // 9. Set the default academic year to 2025-26
        console.log('Step 9: Setting current academic year to 2025-26...');
        await connection.query(`
            INSERT INTO school_settings (key, value, updated_at)
            VALUES ('current_academic_year', '2025-26', CURRENT_TIMESTAMP)
            ON CONFLICT (key) DO UPDATE SET value = '2025-26', updated_at = CURRENT_TIMESTAMP
        `);
        console.log('  -> Academic year set to 2025-26.');

        await connection.commit();
        console.log('--- Migration v3 Completed Successfully ---');
        process.exit(0);
    } catch (err) {
        await connection.rollback();
        console.error('Migration Failed:', err.message);
        process.exit(1);
    } finally {
        connection.release();
    }
}

migrate();
