const { success, error } = require("../../utils/response");
const service = require("./fees_structure.service");

exports.list = async (req, res, next) => {
    try {
        const data = await service.getAllStructures();
        return success(res, data, "Fees structures fetched");
    } catch (err) {
        next(err);
    }
};

exports.save = async (req, res, next) => {
    try {
        const { section_id, amount, description, academic_year } = req.body;
        if (!section_id || amount === undefined) {
            return error(res, "Section ID and amount are required", 400);
        }

        await service.upsertStructure({ section_id, amount, description, academic_year });
        return success(res, null, "Fees structure saved and applied to section");
    } catch (err) {
        next(err);
    }
};

exports.updateIndividual = async (req, res, next) => {
    try {
        const { studentUserId, amount, description } = req.body;
        if (!studentUserId || amount === undefined) {
            return error(res, "Student User ID and amount are required", 400);
        }

        await service.updateIndividualFee(studentUserId, amount, description);
        return success(res, null, "Individual fee updated successfully");
    } catch (err) {
        next(err);
    }
};
