const pool = require('./src/config/db');

async function dump() {
    try {
        console.log('--- Dumping Questions ---');

        // 1. Get Exam ID from Attempt 12
        const [att] = await pool.query('SELECT * FROM online_exam_attempts WHERE id = 12');
        if (att.length) {
            console.log(`Attempt 12 is for Exam ID: ${att[0].exam_id}`);
            const [qs] = await pool.query('SELECT id, question_text, answer_text FROM online_exam_questions WHERE exam_id = ?', [att[0].exam_id]);
            console.log(`Questions for Exam ${att[0].exam_id}:`);
            qs.forEach(q => console.log(`[${q.id}] "${q.question_text}" (Ans: "${q.answer_text}")`));
        } else {
            console.log("Attempt 12 not found.");
        }

        // 2. Search Broadly
        console.log('\n--- Broad Search "photosynthesis" ---');
        const [rows] = await pool.query(`SELECT id, exam_id, question_text, answer_text FROM online_exam_questions WHERE question_text LIKE '%photosynthesis%'`);
        rows.forEach(q => console.log(`[${q.id}] Exam ${q.exam_id}: "${q.question_text}"`));

        process.exit();
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

dump();
