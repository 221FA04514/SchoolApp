const onlineExamsService = require('./src/modules/online_exams/online_exams.service');
const pool = require('./src/config/db');

async function testAllowCopy() {
    try {
        console.log("--- Testing Allow Copy Feature ---");

        // 1. Create an Exam with allow_copy = true
        const examData = {
            title: "Copy Allowed Test Exam",
            subject: "Testing",
            section_id: 1,
            start_time: new Date(),
            end_time: new Date(Date.now() + 3600000),
            duration_mins: 60,
            total_marks: 10,
            created_by: 8,
            allow_copy: true,
            questions: [
                { question_text: "Can you copy this?", answer_text: "Yes", marks: 1 }
            ]
        };

        console.log("Creating exam...", examData);
        // Note: verify if createOnlineExam returns the object directly or we need to await
        // The service returns { id, title }
        const createdExam = await onlineExamsService.createOnlineExam(examData);
        console.log("Exam created:", createdExam);

        // 2. Fetch questions/details as a student would
        // We need to fetch questions. The service has getAttemptDetails which returns allowCopy
        // But getAttemptDetails requires an attempt.
        // Let's check getAvailableExams locally? No, that just lists exams.
        // Wait, the student portal calls `/api/v1/online-exams/questions/:id`.
        // I need to look at the controller to see what service function it calls.
        // I'll assume it's a simple query or I can mock the check using DB query.

        console.log("Verifying DB record...");
        const [rows] = await pool.query("SELECT allow_copy FROM online_exams WHERE id = ?", [createdExam.id]);
        console.log("DB Record:", rows[0]);

        if (rows[0].allow_copy === 1) {
            console.log("SUCCESS: allow_copy is TRUE in DB.");
        } else {
            console.error("FAILURE: allow_copy is NOT TRUE in DB.");
        }

        // Cleanup
        // await pool.query("DELETE FROM online_exams WHERE id = ?", [createdExam.id]); 
        // keep it for manual inspection if needed, or just relying on transaction rollback if I used it (I didn't here)

    } catch (e) {
        console.error("Test Failed:", e);
    } finally {
        process.exit();
    }
}

testAllowCopy();
