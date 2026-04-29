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
        const { section_id, day, period, subject, date, absent_teacher_id } = req.query;
        if (!day || !period || !date) return error(res, "Day, period, and date are required", 400);

        const suggestions = await service.getSubstituteSuggestions(section_id, day, period, subject, date, absent_teacher_id);
        return success(res, suggestions, "Suggestions fetched");
    } catch (err) {
        next(err);
    }
};

exports.getTeacherTimetable = async (req, res, next) => {
    try {
        const { teacher_id, date } = req.query;
        if (!teacher_id) return error(res, "teacher_id is required", 400);
        const useDate = date || new Date().toISOString().split('T')[0];
        const periods = await service.getTeacherTimetableForDay(teacher_id, useDate);
        return success(res, periods, "Teacher timetable fetched");
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

exports.getMyTodaySubstitution = async (req, res, next) => {
    try {
        const userId = req.user.userId;
        const assignments = await service.getMyTodaySubstitution(userId);
        return success(res, assignments, "Today's substitution assignments fetched");
    } catch (err) {
        next(err);
    }
};

exports.deleteSubstitution = async (req, res, next) => {
    try {
        const { id } = req.params;
        if (!id) return error(res, "Substitution ID is required", 400);
        const deleted = await service.deleteSubstitution(id);
        if (!deleted) return error(res, "Substitution not found", 404);
        return success(res, null, "Substitution deleted successfully");
    } catch (err) {
        next(err);
    }
};

