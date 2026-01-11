const { success, error } = require("../../utils/response");
const {
  upsertTimetable,
  getTimetableBySection,
  getStudentTimetable,
  deleteTimetableSlot,
} = require("./timetable.service");

/**
 * Teacher: add / update timetable slot
 */
exports.saveTimetable = async (req, res, next) => {
  try {
    const { role } = req.user;
    const {
      section_id,
      day,
      period,
      subject,
      teacher_name,
      start_time,
      end_time,
    } = req.body;

    if (role !== "teacher" && role !== "admin") {
      return error(res, "Access denied", 403);
    }

    if (
      !section_id ||
      !day ||
      !period ||
      !subject ||
      !teacher_name ||
      !start_time ||
      !end_time
    ) {
      return error(res, "All fields are required", 400);
    }

    await upsertTimetable({
      section_id,
      day,
      period,
      subject,
      teacher_name,
      start_time,
      end_time,
    });

    return success(res, null, "Timetable saved");
  } catch (err) {
    next(err);
  }
};

/**
 * Teacher: view timetable by section
 */
exports.getSectionTimetable = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher" && req.user.role !== "admin") {
      return error(res, "Access denied", 403);
    }

    const { section_id } = req.query;
    if (!section_id) {
      return error(res, "section_id required", 400);
    }

    const data = await getTimetableBySection(section_id);
    return success(res, data, "Timetable fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Student: view own timetable
 */
exports.getMyTimetable = async (req, res, next) => {
  try {
    if (req.user.role !== "student") {
      return error(res, "Access denied", 403);
    }

    const { section_id } = req.user; // make sure section_id is in JWT
    const data = await getStudentTimetable(section_id);

    return success(res, data, "Timetable fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * Admin: delete timetable slot
 */
exports.removeSlot = async (req, res, next) => {
  try {
    if (req.user.role !== "admin") {
      return error(res, "Access denied", 403);
    }

    const { id } = req.params;
    await deleteTimetableSlot(id);
    return success(res, null, "Slot deleted");
  } catch (err) {
    next(err);
  }
};
