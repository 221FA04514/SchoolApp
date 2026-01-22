const aiUtil = require("../../utils/ai.service");
const notifService = require("../notifications/notifications.service");
const { success, error } = require("../../utils/response");
const pool = require("../../config/db");

exports.homeworkHelper = async (req, res) => {
    try {
        const { prompt, image } = req.body; // image is base64
        const analysis = await aiUtil.analyzeHomework(prompt, image);
        success(res, { analysis }, "Homework analyzed successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.solveDoubt = async (req, res) => {
    try {
        const { query, subject } = req.body;
        const studentId = req.user.userId;

        // Simple RAG placeholder: In real app, we'd fetch section-specific context
        const response = await aiUtil.solveDoubt(query);

        // Save to history
        await pool.query(
            "INSERT INTO ai_doubt_history (student_id, prompt, response, subject) VALUES (?, ?, ?, ?)",
            [studentId, query, response, subject]
        );

        success(res, { response }, "Doubt solved");
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
