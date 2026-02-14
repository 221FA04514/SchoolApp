const fs = require('fs');
require('dotenv').config();
const pool = require('./src/config/db');

async function inspectOxygen() {
    try {
        let log = '--- Inspecting Oxygen Mismatch ---\n';

        // Get latest attempt
        const [attempts] = await pool.query('SELECT * FROM online_exam_attempts ORDER BY id DESC LIMIT 1');
        if (!attempts.length) {
            fs.writeFileSync('oxygen_debug.txt', 'No attempts found');
            process.exit();
        }
        const attempt = attempts[0];
        log += `Attempt ID: ${attempt.id}, Student: ${attempt.student_id}\n`;

        // Fetch answers
        const [answers] = await pool.query('SELECT * FROM online_exam_answers WHERE attempt_id = ?', [attempt.id]);

        for (const ans of answers) {
            const [qRow] = await pool.query('SELECT answer_text FROM online_exam_questions WHERE id = ?', [ans.question_id]);
            const dbAnswer = qRow[0].answer_text || "";
            const studentAns = ans.student_answer || "";

            log += `\nQUESTION ID ${ans.question_id}\n`;
            log += `Student: "${studentAns}"\n`;
            log += `DB     : "${dbAnswer}"\n`;

            log += "Student Hex: ";
            for (let i = 0; i < studentAns.length; i++) {
                log += `U+${studentAns.charCodeAt(i).toString(16).toUpperCase().padStart(4, '0')} `;
            }
            log += "\nDB Hex     : ";
            for (let i = 0; i < dbAnswer.length; i++) {
                log += `U+${dbAnswer.charCodeAt(i).toString(16).toUpperCase().padStart(4, '0')} `;
            }
            log += "\n";

            const normStudent = studentAns.toLowerCase().replace(/[^a-z0-9]/g, "");
            const normDb = dbAnswer.toLowerCase().replace(/[^a-z0-9]/g, "");

            log += `Norm Student: '${normStudent}'\n`;
            log += `Norm DB     : '${normDb}'\n`;
            log += `Equal? ${normStudent === normDb}\n`;
        }

        fs.writeFileSync('oxygen_debug.txt', log);
        console.log("Log written to oxygen_debug.txt");
        process.exit();
    } catch (e) {
        fs.writeFileSync('oxygen_error.txt', e.toString());
        process.exit(1);
    }
}

inspectOxygen();
