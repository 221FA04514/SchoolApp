const pool = require("../../config/db");
const { success, error } = require("../../utils/response");
const {
  getAllAnnouncements,
  getAnnouncementById,
  createAnnouncement,
  getTeacherAnnouncements,
  deleteAnnouncement: deleteAnnouncementService,
  dismissAnnouncement,
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
 * Student announcement list — excludes dismissed items
 */
exports.listAnnouncements = async (req, res, next) => {
  try {
    const { role, userId } = req.user;

    if (role !== "student" && role !== "teacher") {
      return error(res, "Access denied", 403);
    }

    let section_id = null;

    if (role === 'student') {
      const [student] = await pool.query("SELECT section_id FROM students WHERE user_id = ?", [userId]);
      section_id = student[0]?.section_id;
    }

    // Pass userId so dismissed items are excluded
    const announcements = await getAllAnnouncements(section_id, userId);
    return success(res, announcements, "Announcements fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * GET /announcements/:id
 */
exports.getAnnouncement = async (req, res, next) => {
  try {
    const { id } = req.params;
    const announcement = await getAnnouncementById(id);
    if (!announcement) return error(res, "Announcement not found", 404);
    return success(res, announcement, "Announcement fetched");
  } catch (err) {
    next(err);
  }
};

/**
 * POST /announcements
 */
exports.createAnnouncement = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { title, description, section_id, scheduled_at, attachment_url, deadline } = req.body;

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
      section_id: section_id || null,
      scheduled_at: scheduled_at || null,
      attachment_url: attachment_url || null,
      deadline: deadline || null,
    });

    return success(res, announcement, "Announcement created successfully");
  } catch (err) {
    next(err);
  }
};

/**
 * DELETE /announcements/:id
 * Teacher/Admin: permanently delete announcement
 */
exports.removeAnnouncement = async (req, res, next) => {
  try {
    const { role } = req.user;
    const { id } = req.params;

    if (role !== "teacher" && role !== "admin") {
      return error(res, "Access denied", 403);
    }

    await deleteAnnouncementService(id);
    return success(res, null, "Announcement deleted successfully");
  } catch (err) {
    if (err.status) return error(res, err.message, err.status);
    next(err);
  }
};

/**
 * POST /announcements/:id/dismiss
 * Student: hide announcement from their view (soft dismiss, not global delete)
 */
exports.dismissAnnouncementForUser = async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    await dismissAnnouncement(id, userId);
    return success(res, null, "Announcement dismissed");
  } catch (err) {
    next(err);
  }
};
