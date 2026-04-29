const settingsService = require("./settings.service");

exports.getAcademicYear = async (req, res) => {
    try {
        const year = await settingsService.getSetting('current_academic_year');
        res.json({ success: true, data: year || '2025-26' });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};

exports.updateAcademicYear = async (req, res) => {
    try {
        const { year } = req.body;
        if (!year) return res.status(400).json({ success: false, message: "Year is required" });

        const result = await settingsService.performAcademicYearTransition(year);

        res.json({
            success: true,
            message: `Academic year transitioned to ${year}. ${result.students_promoted} students promoted, ${result.students_graduated} graduated.`,
            data: result,
        });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
};
