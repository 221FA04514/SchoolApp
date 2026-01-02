const { success, error } = require("../../utils/response");
const {
  getAllAnnouncements,
  getAnnouncementById,
} = require("./announcements.service");

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

    const announcements = await getAllAnnouncements();
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

const { createAnnouncement } = require("./announcements.service");

/**
 * POST /announcements
 * Teacher/Admin creates announcement
 */
exports.createAnnouncement = async (req, res, next) => {
  try {
    const { role, userId } = req.user;
    const { title, description } = req.body;

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
    });

    return success(res, announcement, "Announcement created successfully");
  } catch (err) {
    next(err);
  }
};
