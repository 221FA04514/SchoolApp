const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

exports.applyLeave = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { reason, start_date, end_date } = req.body;

        if (!reason || !start_date || !end_date) {
            return error(res, "All fields are required", 400);
        }

        // We use user_id to identify both teachers and students in the leaves table
        const [result] = await pool.query(
            "INSERT INTO leaves (student_id, reason, start_date, end_date) VALUES (?, ?, ?, ?)",
            [userId, reason, start_date, end_date]
        );

        return success(res, { id: result.insertId }, "Leave application submitted");
    } catch (err) {
        return error(res, err.message);
    }
};

exports.getStudentLeaves = async (req, res) => {
    try {
        const userId = req.user.userId;
        const [rows] = await pool.query(
            "SELECT * FROM leaves WHERE student_id = ? ORDER BY applied_at DESC",
            [userId]
        );
        return success(res, rows, "Leave history retrieved");
    } catch (err) {
        return error(res, err.message);
    }
};

exports.updateLeaveStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // approved, rejected
        const { userId, role } = req.user;

        // If teacher, verify they are the class teacher for this student
        if (role === 'teacher') {
            const [rows] = await pool.query(`
                SELECT m.id 
                FROM leaves l
                JOIN students s ON l.student_id = s.user_id
                JOIN teacher_subject_mappings m ON s.section_id = m.section_id
                JOIN teachers t ON m.teacher_id = t.id
                WHERE l.id = ? AND t.user_id = ? AND m.role = 'class_teacher'
            `, [id, userId]);

            if (rows.length === 0) {
                return error(res, "Unauthorized: You are not the class teacher for this student.", 403);
            }
        } else if (role !== 'admin') {
            return error(res, "Access denied", 403);
        }

        await pool.query("UPDATE leaves SET status = ? WHERE id = ?", [status, id]);
        success(res, null, "Leave status updated");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getAllLeaves = async (req, res) => {
    try {
        const { userId, role } = req.user;
        let query;
        let params = [];

        if (role === 'admin') {
            // Admins see EVERYTHING
            query = `
                SELECT l.*, 
                       COALESCE(s.name, t.name, u.email, 'User') as student_name,
                       u.role as applicant_role
                FROM leaves l 
                JOIN users u ON l.student_id = u.id
                LEFT JOIN students s ON u.id = s.user_id 
                LEFT JOIN teachers t ON u.id = t.user_id
                ORDER BY l.applied_at DESC
            `;
        } else if (role === 'teacher') {
            // Teachers see student leaves where they are the class_teacher
            query = `
                SELECT DISTINCT l.*, 
                       COALESCE(s.name, u.email, 'Student') as student_name
                FROM leaves l 
                JOIN users u ON l.student_id = u.id
                JOIN students s ON u.id = s.user_id
                JOIN teacher_subject_mappings m ON s.section_id = m.section_id
                JOIN teachers t ON m.teacher_id = t.id
                WHERE t.user_id = ? AND m.role = 'class_teacher' AND u.role = 'student'
                ORDER BY l.applied_at DESC
            `;
            params = [userId];
        } else {
            return error(res, "Access denied", 403);
        }

        const [rows] = await pool.query(query, params);
        success(res, rows, "Leave requests retrieved");
    } catch (err) {
        error(res, err.message);
    }
};
