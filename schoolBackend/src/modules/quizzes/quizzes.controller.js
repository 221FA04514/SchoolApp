const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

exports.createQuiz = async (req, res) => {
    try {
        const { section_id, subject, title, questions, total_marks } = req.body;
        const [result] = await pool.query(
            "INSERT INTO quizzes (section_id, subject, title, questions, total_marks) VALUES (?, ?, ?, ?, ?)",
            [section_id, subject, title, JSON.stringify(questions), total_marks]
        );
        success(res, { id: result.insertId }, "Quiz created successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getQuizzes = async (req, res) => {
    try {
        const { section_id } = req.query;
        const [rows] = await pool.query(
            "SELECT id, subject, title, total_marks, created_at FROM quizzes WHERE section_id = ? OR section_id IS NULL",
            [section_id]
        );
        success(res, rows, "Quizzes retrieved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getQuizDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const [rows] = await pool.query("SELECT * FROM quizzes WHERE id = ?", [id]);
        if (rows.length === 0) return error(res, "Quiz not found", 404);

        const quiz = rows[0];
        // Ensure questions are parsed
        quiz.questions = typeof quiz.questions === 'string' ? JSON.parse(quiz.questions) : quiz.questions;

        success(res, quiz, "Quiz details retrieved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.submitAttempt = async (req, res) => {
    try {
        const student_id = req.user.id;
        const { quiz_id, subject, score, total_questions, time_taken_sec, topic } = req.body;

        await pool.query(
            "INSERT INTO quiz_attempts (student_id, subject, score, total_questions, time_taken_sec, topic) VALUES (?, ?, ?, ?, ?, ?)",
            [student_id, subject, score, total_questions, time_taken_sec, topic]
        );

        success(res, null, "Attempt submitted successfully");
    } catch (err) {
        error(res, err.message);
    }
};
