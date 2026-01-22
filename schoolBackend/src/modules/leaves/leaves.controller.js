const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

exports.applyLeave = async (req, res) => {
    try {
        const studentId = req.user.id;
        const { reason, start_date, end_date } = req.body;

        const [result] = await pool.query(
            "INSERT INTO leaves (student_id, reason, start_date, end_date) VALUES (?, ?, ?, ?)",
            [studentId, reason, start_date, end_date]
        );

        success(res, { id: result.insertId }, "Leave application submitted");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getStudentLeaves = async (req, res) => {
    try {
        const studentId = req.user.id;
        const [rows] = await pool.query(
            "SELECT * FROM leaves WHERE student_id = ? ORDER BY applied_at DESC",
            [studentId]
        );
        success(res, rows, "Leave history retrieved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.updateLeaveStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // approved, rejected

        await pool.query("UPDATE leaves SET status = ? WHERE id = ?", [status, id]);
        success(res, null, "Leave status updated");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getAllLeaves = async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT l.*, u.name as student_name 
            FROM leaves l 
            JOIN users u ON l.student_id = u.id 
            ORDER BY l.applied_at DESC
        `);
        success(res, rows, "All leave requests retrieved");
    } catch (err) {
        error(res, err.message);
    }
};
