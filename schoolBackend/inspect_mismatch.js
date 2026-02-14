console.log("DEBUG: Script starting...");
require('dotenv').config();
const pool = require('./src/config/db');

async function inspect() {
    try {
        console.log('--- Inspecting Answers ---');


        // Get latest attempt
        const [attempts] = await pool.query('SELECT * FROM online_exam_attempts ORDER BY id DESC LIMIT 1');
        if (!attempts.length) return;
        const attempt = attempts[0];

        const [answers] = await pool.query('SELECT * FROM online_exam_answers WHERE attempt_id = ?', [attempt.id]);

        for (const ans of answers) {
            const [qRow] = await pool.query('SELECT answer_text FROM online_exam_questions WHERE id = ?', [ans.question_id]);
            const dbAnswer = qRow[0].answer_text || "";
            const studentAns = ans.student_answer || "";

            console.log(`\nQ${ans.question_id}`);
            console.log(`  Student: "${studentAns}"`);
            console.log(`  Correct: "${dbAnswer}"`);

            console.log('  Student Codes:', studentAns.split('').map(c => c.charCodeAt(0)).join(', '));
            console.log('  Correct Codes:', dbAnswer.split('').map(c => c.charCodeAt(0)).join(', '));

            // Test Normalization
            const n1 = studentAns.toLowerCase().replace(/[^\w\s]|_/g, "").replace(/\s+/g, " ").trim();
            const n2 = dbAnswer.toLowerCase().replace(/[^\w\s]|_/g, "").replace(/\s+/g, " ").trim();
            console.log(`  Norm Student: "${n1}"`);
            console.log(`  Norm Correct: "${n2}"`);
            console.log(`  Match? ${n1 === n2}`);
        }
        process.exit();
    } catch (err) {
        console.error("Error inspecting:", err);
    }
}

inspect();
