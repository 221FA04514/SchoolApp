const { success, error } = require("../../utils/response");
const performanceService = require("./performance.service");

exports.addPerformance = async (req, res, next) => {
    try {
        const { role, userId } = req.user;
        const { student_id, performance_rating, remarks } = req.body;

        if (role !== "teacher") {
            return error(res, "Access denied", 403);
        }

        if (!student_id || !performance_rating) {
            return error(res, "student_id and performance_rating are required", 400);
        }

        const newPerf = await performanceService.addPerformance({
            teacher_id: userId,
            student_id,
            performance_rating,
            remarks,
        });

        return success(res, newPerf, "Performance evaluation added successfully");
    } catch (err) {
        next(err);
    }
};

exports.getMyPerformance = async (req, res, next) => {
    try {
        const { role, userId } = req.user;

        if (role !== "student") {
            return error(res, "Access denied", 403);
        }

        const performances = await performanceService.getPerformancesForStudent(userId);
        return success(res, performances, "Performances fetched successfully");
    } catch (err) {
        next(err);
    }
};
