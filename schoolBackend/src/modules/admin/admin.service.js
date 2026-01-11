const pool = require("../../config/db");

/**
 * Get all teachers
 */
exports.getAllTeachers = async () => {
    const [rows] = await pool.query(`
    SELECT u.id as user_id, u.email, t.name, t.subject, t.phone 
    FROM users u 
    INNER JOIN teachers t ON u.id = t.user_id 
    WHERE u.role = 'teacher'
  `);
    return rows;
};

/**
 * Get all students
 */
exports.getAllStudents = async () => {
    const [rows] = await pool.query(`
    SELECT u.id as user_id, u.email, s.name, s.class, s.section, s.roll_number 
    FROM users u 
    INNER JOIN students s ON u.id = s.user_id 
    WHERE u.role = 'student'
  `);
    return rows;
};

/**
 * Get all sections
 */
exports.getAllSections = async () => {
    const [rows] = await pool.query("SELECT * FROM sections ORDER BY name");
    return rows;
};

/**
 * Add a new section
 */
exports.addSection = async (className, section, name) => {
    const [result] = await pool.query(
        "INSERT INTO sections (class, section, name) VALUES (?, ?, ?)",
        [className, section, name]
    );
    return result.insertId;
};

exports.getPeriodSettings = async () => {
    const [rows] = await pool.query("SELECT * FROM period_settings ORDER BY period_number");
    return rows;
};

exports.updatePeriodSetting = async (periodNumber, startTime, endTime) => {
    await pool.query(
        "INSERT INTO period_settings (period_number, start_time, end_time) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE start_time = VALUES(start_time), end_time = VALUES(end_time)",
        [periodNumber, startTime, endTime]
    );
};

exports.deletePeriodSetting = async (id) => {
    await pool.query("DELETE FROM period_settings WHERE id = ?", [id]);
};


/**
 * Delete a section
 */
exports.deleteSection = async (id) => {
    await pool.query("DELETE FROM sections WHERE id = ?", [id]);
};

/**
 * Update teacher details
 */
exports.updateTeacher = async (userId, data) => {
    const { name, subject, phone } = data;
    await pool.query(
        "UPDATE teachers SET name = ?, subject = ?, phone = ? WHERE user_id = ?",
        [name, subject, phone, userId]
    );
};

/**
 * Update student details
 */
exports.updateStudent = async (userId, data) => {
    const { name, class: className, section, roll_number } = data;
    await pool.query(
        "UPDATE students SET name = ?, class = ?, section = ?, roll_number = ? WHERE user_id = ?",
        [name, className, section, roll_number, userId]
    );
};

/**
 * Update user email and optionally password
 */
exports.updateUserAccount = async (userId, email, hashedPassword = null) => {
    if (hashedPassword) {
        await pool.query(
            "UPDATE users SET email = ?, password = ? WHERE id = ?",
            [email, hashedPassword, userId]
        );
    } else {
        await pool.query(
            "UPDATE users SET email = ? WHERE id = ?",
            [email, userId]
        );
    }
};
