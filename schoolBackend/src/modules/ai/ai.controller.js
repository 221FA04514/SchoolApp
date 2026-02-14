const aiUtil = require("../../utils/ai.service");
const notifService = require("../notifications/notifications.service");
const { success, error } = require("../../utils/response");
const pool = require("../../config/db");

exports.homeworkHelper = async (req, res) => {
    try {
        const { prompt, image } = req.body; // image is base64
        const studentId = req.user.userId;
        const analysis = await aiUtil.analyzeHomework(prompt, image);

        // Save to persistent history
        await pool.query(
            "INSERT INTO ai_history (student_id, type, prompt, response, image_path) VALUES (?, 'homework', ?, ?, ?)",
            [studentId, prompt || "Image Analysis", analysis, image ? "image_stored" : null]
        );

        success(res, { analysis }, "Homework analyzed successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.solveDoubt = async (req, res) => {
    try {
        const { query, subject, history } = req.body; // history is optional array of {role, content}
        const studentId = req.user.userId;

        const response = await aiUtil.solveDoubt(query, history);

        // Save to new unified history table
        await pool.query(
            "INSERT INTO ai_history (student_id, type, prompt, response) VALUES (?, 'doubt', ?, ?)",
            [studentId, query, response]
        );

        // Keep legacy save for compatibility if needed, but the UI will use unified
        await pool.query(
            "INSERT INTO ai_doubt_history (student_id, prompt, response, subject) VALUES (?, ?, ?, ?)",
            [studentId, query, response, subject]
        ).catch(err => console.error("Legacy Doubt History Save Error:", err.message));

        success(res, { response }, "Doubt solved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getHistory = async (req, res) => {
    try {
        const studentId = req.user.userId;
        const [history] = await pool.query(
            "SELECT id, type, prompt, response, image_path, created_at FROM ai_history WHERE student_id = ? ORDER BY created_at DESC LIMIT 20",
            [studentId]
        );
        success(res, { history }, "AI History retrieved");
    } catch (err) {
        error(res, err.message);
    }
};

exports.deleteHistoryItem = async (req, res) => {
    try {
        const { id } = req.params;
        const studentId = req.user.userId;

        const [result] = await pool.query(
            "DELETE FROM ai_history WHERE id = ? AND student_id = ?",
            [id, studentId]
        );

        if (result.affectedRows === 0) {
            return error(res, "History item not found or unauthorized", 404);
        }

        success(res, null, "History item deleted successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.getStudyPlan = async (req, res) => {
    try {
        const studentId = req.user.userId;

        // Check if plan exists for this week
        const [existing] = await pool.query(
            "SELECT * FROM study_plans WHERE student_id = ? AND week_start_date >= CURDATE() - INTERVAL 7 DAY",
            [studentId]
        );

        if (existing.length > 0) {
            return success(res, existing[0], "Study plan retrieved");
        }

        // Fetch student context for better planning
        const [results] = await pool.query("SELECT * FROM results WHERE student_id = ?", [studentId]);
        const rawPlan = await aiUtil.generateStudyPlan({ results });

        // Robust JSON parsing (handles AI returning ```json ... ```)
        let planJson = rawPlan;
        try {
            const jsonMatch = rawPlan.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                planJson = jsonMatch[0];
                JSON.parse(planJson); // Validate
            }
        } catch (e) {
            console.warn("AI returned invalid JSON, saving as raw text");
        }

        const [insert] = await pool.query(
            "INSERT INTO study_plans (student_id, week_start_date, plan_json) VALUES (?, CURDATE(), ?)",
            [studentId, planJson]
        );

        success(res, { id: insert.insertId, plan_json: planJson }, "New study plan generated");
    } catch (err) {
        console.error("Study Plan Generation Error:", err);
        error(res, err.message);
    }
};

/**
 * Teacher: Generate AI Homework
 */
exports.generateHomework = async (req, res) => {
    try {
        const { subject, topic, difficulty, count } = req.body;
        if (req.user.role !== "teacher") return error(res, "Access denied", 403);

        const rawJson = await aiUtil.generateSmartHomework({ subject, topic, difficulty, count });

        let questions = [];
        try {
            // Remove markdown code blocks if present
            const cleanRaw = rawJson.replace(/```json|```/g, "").trim();
            const jsonMatch = cleanRaw.match(/\{[\s\S]*\}|\[[\s\S]*\]/);
            if (jsonMatch) {
                const parsed = JSON.parse(jsonMatch[0]);
                questions = Array.isArray(parsed) ? parsed : (parsed.questions || []);
            }
        } catch (e) {
            console.error("AI returned invalid JSON for homework:", e.message);
        }

        success(res, { questions }, "AI Homework generated");
    } catch (err) {
        error(res, err.message);
    }
};

/**
 * Teacher: Refine Announcement
 */
exports.refineAnnouncement = async (req, res) => {
    try {
        const { draft } = req.body;
        if (req.user.role !== "teacher") return error(res, "Access denied", 403);

        const refined = await aiUtil.refineAnnouncement(draft);
        success(res, { refined }, "Announcement refined");
    } catch (err) {
        error(res, err.message);
    }
};

/**
 * Teacher: Get Student Insights
 */
exports.getStudentInsights = async (req, res) => {
    try {
        const { studentId } = req.params;
        if (req.user.role !== "teacher") return error(res, "Access denied", 403);

        // Fetch student context (attendance summary + latest marks)
        const [attendance] = await pool.query(
            "SELECT status, COUNT(*) as count FROM attendance WHERE student_id = ? GROUP BY status",
            [studentId]
        );
        const [marks] = await pool.query(
            "SELECT subject, marks FROM results WHERE student_id = ? ORDER BY created_at DESC LIMIT 10",
            [studentId]
        );
        const [student] = await pool.query("SELECT name FROM students WHERE user_id = ?", [studentId]);

        const insights = await aiUtil.getPerformanceInsights(
            student[0]?.name || "Student",
            { attendance, marks }
        );

        success(res, { insights }, "Performance insights generated");
    } catch (err) {
        error(res, err.message);
    }
};

/**
 * Teacher: Get Detailed Insight Lists
 */
exports.getInsightDetails = async (req, res) => {
    try {
        const { type } = req.query; // 'low_attendance' or 'ungraded_homework'
        if (req.user.role !== "teacher") return error(res, "Access denied", 403);

        const teacherId = req.user.userId;

        if (type === "low_attendance") {
            // Find students with attendance < 75% in the last 30 days
            const [students] = await pool.query(`
                SELECT s.user_id as id, s.name, s.roll_number, 
                ROUND((COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / COUNT(a.id)), 1) as percentage
                FROM students s
                JOIN attendance a ON s.user_id = a.student_id
                WHERE a.date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                GROUP BY s.user_id
                HAVING percentage < 75
                ORDER BY percentage ASC
            `);
            return success(res, { students }, "Attendance alerts fetched");
        }

        if (type === "ungraded_homework") {
            // Find homework with pending submissions
            const [pending] = await pool.query(`
                SELECT h.id as homework_id, h.title, h.due_date,
                COUNT(hs.id) as submission_count
                FROM homework h
                JOIN homework_submissions hs ON h.id = hs.homework_id
                WHERE h.created_by = ? AND hs.status = 'submitted'
                GROUP BY h.id
                HAVING submission_count > 0
            `, [teacherId]);
            return success(res, { pending }, "Ungraded homework queue fetched");
        }

        error(res, "Invalid insight type");
    } catch (err) {
        error(res, err.message);
    }
};
