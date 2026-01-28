const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

exports.uploadResource = async (req, res) => {
    try {
        console.log("[DEBUG] Upload Body:", req.body);
        console.log("[DEBUG] Upload File:", req.file);

        if (!req.file) {
            return error(res, "No file uploaded", 400);
        }

        const { section_id, subject, title, type, description } = req.body;
        const file_url = `/uploads/resources/${req.file.filename}`;
        const uploaded_by = req.user.userId;

        const [result] = await pool.query(
            "INSERT INTO resources (section_id, subject, title, description, file_url, type, uploaded_by) VALUES (?, ?, ?, ?, ?, ?, ?)",
            [section_id, subject, title, description || '', file_url, type, uploaded_by]
        );

        success(res, { id: result.insertId, file_url }, "Resource uploaded successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getResources = async (req, res) => {
    try {
        // Students see resources for their section
        // Teachers/Admins might see all or filter
        const { section_id } = req.query;

        let query = `
            SELECT r.*, 
                   COALESCE(t.name, s.name, 'Admin') as uploader_name, 
                   sec.name as section_name 
            FROM resources r 
            LEFT JOIN teachers t ON r.uploaded_by = t.user_id
            LEFT JOIN students s ON r.uploaded_by = s.user_id
            LEFT JOIN sections sec ON r.section_id = sec.id
        `;
        let params = [];

        if (req.user.role === "student") {
            // Force filter by student's own section
            const [std] = await pool.query("SELECT section_id FROM students WHERE user_id = ?", [req.user.userId]);
            const mySectionId = std[0]?.section_id;

            query += " WHERE r.section_id = ? OR r.section_id IS NULL";
            params.push(mySectionId);
        } else if (section_id) {
            query += " WHERE r.section_id = ? OR r.section_id IS NULL";
            params.push(section_id);
        }

        const [rows] = await pool.query(query, params);
        success(res, rows, "Resources retrieved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.deleteResource = async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query("DELETE FROM resources WHERE id = ?", [id]);
        success(res, null, "Resource deleted");
    } catch (err) {
        error(res, err.message);
    }
};
