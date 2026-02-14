const pool = require('./src/config/db');

async function inspectOnlineResults() {
    try {
        console.log('--- Inspecting Online Exam Attempts ---');
        const [attempts] = await pool.query('SELECT * FROM online_exam_attempts ORDER BY id DESC LIMIT 5');
        console.log(JSON.stringify(attempts, null, 2));

        if (attempts.length > 0) {
            const lastAttempt = attempts[0];
            console.log('\n--- Inspecting Student Record ---');
            // Check if lastAttempt.student_id is treated as a user_id or student_id.
            // The service assumes it is user_id.
            const [studentByUser] = await pool.query('SELECT * FROM students WHERE user_id = ?', [lastAttempt.student_id]);
            const [studentById] = await pool.query('SELECT * FROM students WHERE id = ?', [lastAttempt.student_id]);

            console.log('Student by user_id:', JSON.stringify(studentByUser, null, 2));
            console.log('Student by id:', JSON.stringify(studentById, null, 2));

            console.log('\n--- Inspecting Linked Exam ---');
            const [exam] = await pool.query('SELECT * FROM online_exams WHERE id = ?', [lastAttempt.exam_id]);
            console.log(JSON.stringify(exam, null, 2));

            if (exam.length > 0 && exam[0].linked_exam_id) {
                console.log(`\n--- Inspecting Linked Exam in 'exams' table (ID: ${exam[0].linked_exam_id}) ---`);
                const [linkedExam] = await pool.query('SELECT * FROM exams WHERE id = ?', [exam[0].linked_exam_id]);
                console.log('Linked Exam:', JSON.stringify(linkedExam, null, 2));

                console.log(`\n--- Inspecting Results for Exam ID ${exam[0].linked_exam_id} ---`);
                const actualStudentId = studentByUser[0]?.id;
                console.log(`Using actual student ID: ${actualStudentId}`);
                const [results] = await pool.query('SELECT * FROM results WHERE exam_id = ? AND student_id = ?', [exam[0].linked_exam_id, actualStudentId]);

                // Check results schema
                const [columns] = await pool.query('SHOW COLUMNS FROM results');

                const debugData = {
                    lastAttempt,
                    studentByUser: studentByUser[0],
                    studentById: studentById[0],
                    exam: exam[0],
                    linkedExam: linkedExam[0],
                    results,
                    resultsColumns: columns.map(c => c.Field)
                };
                require('fs').writeFileSync('debug_out.json', JSON.stringify(debugData, null, 2));
                console.log('Written to debug_out.json');
            } else {
                console.log('\n[!] No linked_exam_id found for this online exam.');
            }
        }
    } catch (err) {
        console.error(err);
    } finally {
        process.exit();
    }
}

inspectOnlineResults();
