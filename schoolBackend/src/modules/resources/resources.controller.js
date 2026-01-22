const pool = require("../../config/db");
const { success, error } = require("../../utils/response");

exports.uploadResource = async (req, res) => {
    try {
        const { section_id, subject, title, type } = req.body;
        const file_url = `/uploads/resources/${req.file.filename}`;
        const uploaded_by = req.user.id;

        const [result] = await pool.query(
            "INSERT INTO resources (section_id, subject, title, file_url, type, uploaded_by) VALUES (?, ?, ?, ?, ?, ?)",
            [section_id, subject, title, file_url, type, uploaded_by]
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

        let query = "SELECT r.*, u.name as uploader_name FROM resources r LEFT JOIN users u ON r.uploaded_by = u.id";
        let params = [];

        if (section_id) {
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
