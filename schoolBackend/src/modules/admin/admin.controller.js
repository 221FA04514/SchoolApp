const { success, error } = require("../../utils/response");
const adminService = require("./admin.service");
const pool = require("../../config/db");
const bcrypt = require("bcrypt");

exports.getTeachers = async (req, res, next) => {
    try {
        const data = await adminService.getAllTeachers();
        return success(res, data, "Teachers fetched");
    } catch (err) {
        next(err);
    }
};

exports.getStudents = async (req, res, next) => {
    try {
        const [rows] = await pool.query(`
            SELECT u.id as user_id, u.email, s.name, s.class, s.section, s.roll_number, s.section_id, sec.name as section_name
            FROM users u 
            INNER JOIN students s ON u.id = s.user_id 
            LEFT JOIN sections sec ON s.section_id = sec.id
            WHERE u.role = 'student'
        `);
        return success(res, rows, "Students fetched");
    } catch (err) {
        next(err);
    }
};

exports.getSections = async (req, res, next) => {
    try {
        const data = await adminService.getAllSections();
        return success(res, data, "Sections fetched");
    } catch (err) {
        next(err);
    }
};

exports.createSection = async (req, res, next) => {
    try {
        const { class: className, section } = req.body;
        if (!className || !section) return error(res, "Class and Section required", 400);

        const name = `${className}${section}`;
        const id = await adminService.addSection(className, section, name);
        return success(res, { id, name, class: className, section }, "Section created");
    } catch (err) {
        next(err);
    }
};

exports.removeSection = async (req, res, next) => {
    try {
        const { id } = req.params;
        await adminService.deleteSection(id);
        return success(res, null, "Section deleted");
    } catch (err) {
        next(err);
    }
};

/**
 * Helper to register a user with a specific role
 */
exports.registerUser = async (req, res, next) => {
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    try {
        const { email, password, role, name, ...extraData } = req.body;

        if (!email || !password || !role || !name) {
            return error(res, "Missing required fields", 400);
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const [userResult] = await connection.query(
            "INSERT INTO users (email, password, role) VALUES (?, ?, ?)",
            [email, hashedPassword, role]
        );

        const userId = userResult.insertId;

        if (role === "teacher") {
            await connection.query(
                "INSERT INTO teachers (user_id, name, subject, phone) VALUES (?, ?, ?, ?)",
                [userId, name, extraData.subject, extraData.phone]
            );
        } else if (role === "student") {
            const [sections] = await connection.query(
                "SELECT id FROM sections WHERE class = ? AND section = ?",
                [extraData.class, extraData.section]
            );
            const sectionId = sections.length > 0 ? sections[0].id : null;

            await connection.query(
                "INSERT INTO students (user_id, name, class, section, roll_number, section_id) VALUES (?, ?, ?, ?, ?, ?)",
                [userId, name, extraData.class, extraData.section, extraData.roll_number, sectionId]
            );
        }

        await connection.commit();
        return success(res, { userId }, "User registered successfully");
    } catch (err) {
        await connection.rollback();
        next(err);
    } finally {
        connection.release();
    }
};

/**
 * Update an existing user (teacher or student)
 */
exports.updateUser = async (req, res, next) => {
    const connection = await pool.getConnection();
    await connection.beginTransaction();
    try {
        const { id } = req.params;
        const { email, password, role, name, ...extraData } = req.body;

        if (!email || !role || !name) {
            return error(res, "Missing required fields", 400);
        }

        let hashedPassword = null;
        if (password && password.trim().length > 0) {
            hashedPassword = await bcrypt.hash(password, 10);
        }

        // 1. Update core user info
        if (hashedPassword) {
            await connection.query(
                "UPDATE users SET email = ?, password = ? WHERE id = ?",
                [email, hashedPassword, id]
            );
        } else {
            await connection.query(
                "UPDATE users SET email = ? WHERE id = ?",
                [email, id]
            );
        }

        // 2. Update role-specific details
        if (role === "teacher") {
            await connection.query(
                "UPDATE teachers SET name = ?, subject = ?, phone = ? WHERE user_id = ?",
                [name, extraData.subject, extraData.phone, id]
            );
        } else if (role === "student") {
            const [sections] = await connection.query(
                "SELECT id FROM sections WHERE class = ? AND section = ?",
                [extraData.class, extraData.section]
            );
            const sectionId = sections.length > 0 ? sections[0].id : null;

            await connection.query(
                "UPDATE students SET name = ?, class = ?, section = ?, roll_number = ?, section_id = ? WHERE user_id = ?",
                [name, extraData.class, extraData.section, extraData.roll_number, sectionId, id]
            );
        }

        await connection.commit();
        return success(res, null, "User updated successfully");
    } catch (err) {
        await connection.rollback();
        next(err);
    } finally {
        connection.release();
    }
};
exports.listPeriodSettings = async (req, res, next) => {
    try {
        const data = await adminService.getPeriodSettings();
        return success(res, data, "Period settings fetched");
    } catch (err) {
        next(err);
    }
};

exports.savePeriodSetting = async (req, res, next) => {
    try {
        const { period_number, start_time, end_time } = req.body;
        if (!period_number || !start_time || !end_time) {
            return error(res, "Missing required fields", 400);
        }
        await adminService.updatePeriodSetting(period_number, start_time, end_time);
        return success(res, null, "Period setting saved");
    } catch (err) {
        next(err);
    }
};

exports.removePeriodSetting = async (req, res, next) => {
    try {
        const { id } = req.params;
        await adminService.deletePeriodSetting(id);
        return success(res, null, "Period setting deleted");
    } catch (err) {
        next(err);
    }
};
