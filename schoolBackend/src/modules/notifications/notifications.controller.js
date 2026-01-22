const notifService = require("./notifications.service");
const { success, error } = require("../../utils/response");

exports.getNotifications = async (req, res) => {
    try {
        const userId = req.user.id;
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
