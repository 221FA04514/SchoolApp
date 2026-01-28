const pool = require("../../config/db");

exports.createOnlineExam = async ({ title, subject, section_id, start_time, end_time, duration_mins, total_marks, created_by, questions }) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Create entry in primary exams table for visibility in Results module
        const [primaryResult] = await connection.query(
            `INSERT INTO exams (name, class, exam_date, section_id, total_marks, passing_marks, created_by, is_published)
       VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)`,
            [title, "Online", start_time, section_id, total_marks, Math.floor(total_marks * 0.35), created_by]
        );
        const linkedExamId = primaryResult.insertId;

        // 2. Create entry in online_exams table
        const [examResult] = await connection.query(
            `INSERT INTO online_exams (title, subject, section_id, start_time, end_time, duration_mins, total_marks, created_by, linked_exam_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [title, subject, section_id, start_time, end_time, duration_mins, total_marks, created_by, linkedExamId]
        );

        const examId = examResult.insertId;

        for (const q of questions) {
            await connection.query(
                `INSERT INTO online_exam_questions (exam_id, question_text, answer_text, options_json, marks)
         VALUES (?, ?, ?, ?, ?)`,
                [examId, q.question_text, q.answer_text, q.options_json ? JSON.stringify(q.options_json) : null, q.marks || 1]
            );
        }

        await connection.commit();
        return { id: examId, title };
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};

exports.getAvailableExams = async (studentId, sectionId) => {
    const [rows] = await pool.query(
        `SELECT e.*, 
            (SELECT status FROM online_exam_attempts WHERE exam_id = e.id AND student_id = ?) as attempt_status
     FROM online_exams e
     WHERE e.section_id = ? AND NOW() <= e.end_time
     ORDER BY e.start_time DESC`,
        [studentId, sectionId]
    );
    return rows;
};

exports.getExamQuestions = async (examId) => {
    const [rows] = await pool.query(
        `SELECT id, question_text, options_json, marks FROM online_exam_questions WHERE exam_id = ?`,
        [examId]
    );
    return rows;
};

exports.startAttempt = async (examId, studentId) => {
    const [result] = await pool.query(
        `INSERT INTO online_exam_attempts (exam_id, student_id, start_time, status)
     VALUES (?, ?, NOW(), 'started')`,
        [examId, studentId]
    );
    return result.insertId;
};

exports.submitAttempt = async (attemptId, answers) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        let totalMarks = 0;
        for (const ans of answers) {
            const [qRow] = await connection.query(`SELECT answer_text, marks FROM online_exam_questions WHERE id = ?`, [ans.question_id]);
            const isCorrect = qRow[0].answer_text === ans.student_answer;
            const marksAwarded = isCorrect ? qRow[0].marks : 0;
            totalMarks += marksAwarded;

            await connection.query(
                `INSERT INTO online_exam_answers (attempt_id, question_id, student_answer, is_correct, marks_awarded)
         VALUES (?, ?, ?, ?, ?)`,
                [attemptId, ans.question_id, ans.student_answer, isCorrect, marksAwarded]
            );
        }

        await connection.query(
            `UPDATE online_exam_attempts SET submit_time = NOW(), marks_obtained = ?, status = 'submitted' WHERE id = ?`,
            [totalMarks, attemptId]
        );

        // Sync to results table for student visibility
        const [attRow] = await connection.query(`SELECT exam_id, student_id as user_id FROM online_exam_attempts WHERE id = ?`, [attemptId]);
        const userId = attRow[0].user_id;

        // Get actual student_id from students table (not user_id)
        const [studentRow] = await connection.query(`SELECT id FROM students WHERE user_id = ?`, [userId]);
        const actualStudentId = studentRow[0]?.id;

        if (!actualStudentId) {
            console.error(`[EXAM] Could not find student record for user_id: ${userId}`);
            await connection.commit();
            return;
        }

        const [exRow] = await connection.query(`SELECT title, subject, linked_exam_id FROM online_exams WHERE id = ?`, [attRow[0].exam_id]);

        // Check if result already exists to avoid duplicate
        await connection.query(
            `INSERT INTO results (student_id, subject, marks, remarks, exam_id)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE marks = VALUES(marks)`,
            [actualStudentId, exRow[0].subject, totalMarks, "Online Exam: " + exRow[0].title, exRow[0].linked_exam_id]
        );

        await connection.commit();
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};
