const notifService = require("./notifications.service");
const { success, error } = require("../../utils/response");

exports.getNotifications = async (req, res) => {
    try {
        // Fix: use userId from JWT token (req.user.userId), not req.user.id
        const userId = req.user.userId;
        const notifications = await notifService.getUserNotifications(userId);
        success(res, notifications, "Notifications retrieved successfully");
    } catch (err) {
        error(res, err.message);
    }
};

exports.markRead = async (req, res) => {
    try {
        const { id } = req.params;
        await notifService.markAsRead(id);
        success(res, null, "Notification marked as read");
    } catch (err) {
        error(res, err.message);
    }
};

exports.removeNotification = async (req, res) => {
    try {
        const { id } = req.params;
        // Soft delete — scoped to the requesting user
        const userId = req.user.userId;
        await notifService.deleteNotification(id, userId);
        success(res, null, "Notification removed");
    } catch (err) {
        error(res, err.message);
    }
};
