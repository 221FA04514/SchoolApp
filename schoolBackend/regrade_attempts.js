const pool = require('./src/config/db');

function normalizeString(str) {
    if (!str) return "";
    // Aggressive normalization: keep ONLY lowercase alphanumeric characters
    // This removes spaces, punctuation, symbols, and invisible characters
    return str.toLowerCase().replace(/[^a-z0-9]/g, "");
}

async function regradeAllAttempts() {
    console.log('--- Starting UNIVERSAL Regrade Process ---');

    // 1. Get ALL submitted attempts
    const [attempts] = await pool.query("SELECT * FROM online_exam_attempts WHERE status = 'submitted'");
    console.log(`Found ${attempts.length} submitted attempts to regrade.`);

    for (const attempt of attempts) {
        console.log(`Regrading Attempt ID: ${attempt.id} (Student: ${attempt.student_id})`);

        // 2. Fetch answers given in this attempt
        const [answers] = await pool.query('SELECT * FROM online_exam_answers WHERE attempt_id = ?', [attempt.id]);

        let totalMarks = 0;

        for (const ans of answers) {
            // 3. Get correct answer
            const [qRow] = await pool.query('SELECT answer_text, marks FROM online_exam_questions WHERE id = ?', [ans.question_id]);
            if (qRow.length === 0) continue;

            const dbAnswer = qRow[0].answer_text || "";
            const studentAns = ans.student_answer || "";

            // 4. Normalize and Compare
            const normDb = normalizeString(dbAnswer);
            const normStudent = normalizeString(studentAns);

            const isCorrect = normDb === normStudent;
            const marksAwarded = isCorrect ? qRow[0].marks : 0;

            // console.log(`Q${ans.question_id}:`);
            // console.log(`  Student: "${studentAns}" -> "${normStudent}"`);
            // console.log(`  Correct: "${dbAnswer}"   -> "${normDb}"`);
            // console.log(`  Result : ${isCorrect ? "CORRECT" : "WRONG"} (Marks: ${marksAwarded})`);

            totalMarks += marksAwarded;

            // 5. Update answer record
            await pool.query(
                'UPDATE online_exam_answers SET is_correct = ?, marks_awarded = ? WHERE id = ?',
                [isCorrect, marksAwarded, ans.id]
            );
        }

        // 6. Update attempt record
        console.log(`  Total Marks: ${totalMarks}`);
        await pool.query(
            'UPDATE online_exam_attempts SET marks_obtained = ? WHERE id = ?',
            [totalMarks, attempt.id]
        );

        // 7. Sync to results table
        // Fetch linked exam id
        const [exRow] = await pool.query(`SELECT linked_exam_id, title, subject FROM online_exams WHERE id = ?`, [attempt.exam_id]);
        if (exRow.length === 0) continue;

        const linkedExamId = exRow[0].linked_exam_id;

        // Fetch actual student id
        const [attRow] = await pool.query(`SELECT student_id as user_id FROM online_exam_attempts WHERE id = ?`, [attempt.id]);
        const userId = attRow[0].user_id;
        const [studentRow] = await pool.query(`SELECT id FROM students WHERE user_id = ?`, [userId]);
        const actualStudentId = studentRow[0]?.id;

        if (actualStudentId && linkedExamId) {
            // console.log(`Syncing to results: Student=${actualStudentId}, Exam=${linkedExamId}, Marks=${totalMarks}`);
            await pool.query(
                `INSERT INTO results (student_id, subject, marks, remarks, exam_id)
                 VALUES (?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE marks = VALUES(marks)`,
                [actualStudentId, exRow[0].subject, totalMarks, "Online Exam: " + exRow[0].title, linkedExamId]
            );
        }
    }

    console.log('--- Universal Regrade Complete ---');
    process.exit();
}

regradeAllAttempts();
