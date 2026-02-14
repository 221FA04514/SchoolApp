const pool = require('./src/config/db');

async function findQuestion() {
    try {
        console.log('--- Searching for Question ---');
        // Find question ID
        const [qs] = await pool.query(`SELECT * FROM online_exam_questions WHERE question_text LIKE '%Plants release%'`);

        if (qs.length === 0) {
            console.log("Question NOT FOUND");
            process.exit();
        }

        for (const q of qs) {
            console.log(`\nFound QID: ${q.id} (Exam: ${q.exam_id})`);
            console.log(`Text: "${q.question_text}"`);
            console.log(`Correct: "${q.answer_text}"`);

            // Find latest answer for this question
            const [ans] = await pool.query(
                `SELECT a.*, att.student_id 
                 FROM online_exam_answers a 
                 JOIN online_exam_attempts att ON a.attempt_id = att.id
                 WHERE a.question_id = ? 
                 ORDER BY a.id DESC LIMIT 3`,
                [q.id]
            );

            console.log("Recent Answers:");
            for (const a of ans) {
                console.log(`  Attempt ${a.attempt_id} (Student ${a.student_id}): "${a.student_answer}" -> Correct? ${a.is_correct}`);

                // Hex dump
                const s = a.student_answer || "";
                const c = q.answer_text || "";

                const normS = s.toLowerCase().replace(/[^a-z0-9]/g, "");
                const normC = c.toLowerCase().replace(/[^a-z0-9]/g, "");

                console.log(`    Norm Student: '${normS}'`);
                console.log(`    Norm Correct: '${normC}'`);
                console.log(`    Match? ${normS === normC}`);
            }
        }
        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

findQuestion();
