const { success, error } = require("../../utils/response");
const service = require("./substitutions.service");

exports.markAbsent = async (req, res, next) => {
    try {
        const { teacher_id, absence_date, reason } = req.body;
        const marked_by = req.user.userId;

        if (!teacher_id || !absence_date) {
            return error(res, "Teacher ID and date are required", 400);
        }

        const absenceId = await service.markAbsent({ teacher_id, absence_date, reason, marked_by });

        // Fetch impacted periods automatically
        const impacted = await service.getImpactedPeriods(teacher_id, absence_date);

        return success(res, { absenceId, impacted }, "Teacher marked absent. Impacted classes identified.");
    } catch (err) {
        next(err);
    }
};

exports.getSuggestions = async (req, res, next) => {
    try {
        const { section_id, day, period, subject } = req.query;
        if (!day || !period) return error(res, "Day and period are required", 400);

        const suggestions = await service.getSubstituteSuggestions(section_id, day, period, subject);
        return success(res, suggestions, "Suggestions fetched");
    } catch (err) {
        next(err);
    }
};

exports.assign = async (req, res, next) => {
    try {
        const id = await service.assignSubstitution(req.body);
        return success(res, { id }, "Substitution assigned successfully");
    } catch (err) {
        next(err);
    }
};

exports.listDaySubstitutions = async (req, res, next) => {
    try {
        const { date } = req.query;
        const list = await service.getSubstitutionsForDay(date || new Date().toISOString().split('T')[0]);
        return success(res, list, "Substitutions fetched");
    } catch (err) {
        next(err);
    }
};
