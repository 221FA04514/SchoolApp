const { success, error } = require("../../utils/response");
const {
  getAllAnnouncements,
  getAnnouncementById,
  createAnnouncement,
  getTeacherAnnouncements,
} = require("./announcements.service");



/**
 * Teacher: view own announcements
 */
exports.getTeacherAnnouncements = async (req, res, next) => {
  try {
    if (req.user.role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    const data = await getTeacherAnnouncements(req.user.userId);
    return success(res, data, "Announcements fetched");
  } catch (err) {
    next(err);
  }
};


/**
 * GET /announcements
 * Student announcement list
 */
exports.listAnnouncements = async (req, res, next) => {
  try {
    const { role } = req.user;

    if (role !== "student") {
      return error(res, "Access denied", 403);
    }

    // Get student's section_id
    const [student] = await pool.query("SELECT section_id FROM students WHERE user_id = ?", [req.user.userId]);
    const section_id = student[0]?.section_id;

    const announcements = await getAllAnnouncements(section_id);
    return success(res, announcements, "Announcements fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * GET /announcements/:id
 * Announcement detail page
 */
exports.getAnnouncement = async (req, res, next) => {
  try {
    const { id } = req.params;

    const announcement = await getAnnouncementById(id);
    if (!announcement) {
      return error(res, "Announcement not found", 404);
    }

    return success(res, announcement, "Announcement fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * POST /announcements
 * Teacher/Admin creates announcement
 */
exports.createAnnouncement = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { title, description, section_id, scheduled_at, attachment_url } = req.body;

    if (role !== "teacher" && role !== "admin") {
      return error(res, "Access denied", 403);
    }

    if (!title || !description) {
      return error(res, "Title and description are required", 400);
    }

    const announcement = await createAnnouncement({
      title,
      description,
      created_by: userId,
      role,
      section_id,
      scheduled_at,
      attachment_url,
    });

    return success(res, announcement, "Announcement created successfully");
  } catch (err) {
    next(err);
  }
};
