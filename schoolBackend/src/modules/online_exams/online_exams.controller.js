const { success, error } = require("../../utils/response");
const onlineExamsService = require("./online_exams.service");

exports.createExam = async (req, res, next) => {
    try {
        const { role, userId } = req.user;
        if (role !== "teacher") return error(res, "Access denied", 403);

        const exam = await onlineExamsService.createOnlineExam({
            ...req.body,
            created_by: userId,
        });
        return success(res, exam, "Online exam created successfully");
    } catch (err) {
        next(err);
    }
};

exports.listAvailableExams = async (req, res, next) => {
    try {
        const { role, userId } = req.user;
        if (role !== "student") return error(res, "Access denied", 403);

        // Fetch student's student_id and section_id
        const pool = require("../../config/db");
        const [std] = await pool.query("SELECT id, section_id FROM students WHERE user_id = ?", [userId]);
        if (!std[0]) return error(res, "Student not found", 404);

        const studentId = std[0].id;
        const sectionId = std[0].section_id;

        const exams = await onlineExamsService.getAvailableExams(studentId, sectionId);
        return success(res, exams, "Exams fetched");
    } catch (err) {
        next(err);
    }
};

exports.getQuestions = async (req, res, next) => {
    try {
        const { examId } = req.params;
        const questions = await onlineExamsService.getExamQuestions(examId);
        return success(res, questions, "Questions fetched");
    } catch (err) {
        next(err);
    }
};

exports.startAttempt = async (req, res, next) => {
    try {
        const { examId } = req.body;
        const { userId } = req.user;

        // Resolve studentId
        const pool = require("../../config/db");
        const [std] = await pool.query("SELECT id FROM students WHERE user_id = ?", [userId]);
        if (!std[0]) return error(res, "Student not found", 404);

        const attemptId = await onlineExamsService.startAttempt(examId, std[0].id);
        return success(res, { attemptId }, "Attempt started");
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return error(res, "You have already attempted this exam", 400);
        }
        next(err);
    }
};

exports.submitAttempt = async (req, res, next) => {
    try {
        const { attemptId, answers } = req.body;
        await onlineExamsService.submitAttempt(attemptId, answers);
        return success(res, null, "Exam submitted successfully");
    } catch (err) {
        next(err);
    }
};
