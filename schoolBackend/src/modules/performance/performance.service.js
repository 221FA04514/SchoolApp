const pool = require("../../config/db");

exports.addPerformance = async ({ teacher_id, student_id, performance_rating, remarks }) => {
    const [result] = await pool.query(
        `INSERT INTO student_performances (teacher_id, student_id, performance_rating, remarks)
     VALUES (?, ?, ?, ?)`,
        [teacher_id, student_id, performance_rating, remarks || ""]
    );

    return {
        id: result.insertId,
        teacher_id,
        student_id,
        performance_rating,
        remarks,
    };
};

exports.getPerformancesForStudent = async (student_id) => {
    const [rows] = await pool.query(
        `SELECT sp.*, t.name as teacher_name 
     FROM student_performances sp
     JOIN teachers t ON sp.teacher_id = t.user_id
     WHERE sp.student_id = ?
     ORDER BY sp.created_at DESC`,
        [student_id]
    );
    return rows;
};
