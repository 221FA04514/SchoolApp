const { success, error } = require("../../utils/response");
const { createMapping, getMappings, deactivateMapping } = require("./mapping.service");

exports.create = async (req, res, next) => {
    try {
        const { teacher_id, section_id, subject_name, role, academic_year } = req.body;
        const performedBy = req.user.userId;

        if (!teacher_id || !section_id || !subject_name || !academic_year) {
            return error(res, "Missing required fields", 400);
        }

        const id = await createMapping({ teacher_id, section_id, subject_name, role, academic_year, performedBy });
        return success(res, { id }, "Mapping created successfully");
    } catch (err) {
        if (err.code === 'ER_DUP_ENTRY') {
            return error(res, "Mapping already exists for this combination", 409);
        }
        next(err);
    }
};

exports.list = async (req, res, next) => {
    try {
        const mappings = await getMappings(req.query);
        return success(res, mappings, "Mappings fetched successfully");
    } catch (err) {
        next(err);
    }
};

exports.remove = async (req, res, next) => {
    try {
        const { id } = req.params;
        const performedBy = req.user.userId;

        await deactivateMapping(id, performedBy);
        return success(res, null, "Mapping deactivated successfully");
    } catch (err) {
        next(err);
    }
};
