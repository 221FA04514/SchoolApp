const { success, error } = require("../../utils/response");
const service = require("./mass_notifications.service");
const aiService = require("../../utils/ai.service");

exports.send = async (req, res, next) => {
    try {
        const { title, body, attachment_url, scheduled_at, expires_at, targets } = req.body;
        const created_by = req.user.userId;

        if (!title || !body || !targets || !targets.length) {
            return error(res, "Title, body, and at least one target are required", 400);
        }

        const id = await service.createMassNotification({ title, body, attachment_url, created_by, scheduled_at, expires_at, targets });
        return success(res, { id }, "Notification sent/scheduled successfully");
    } catch (err) {
        next(err);
    }
};

exports.formalize = async (req, res, next) => {
    try {
        const { text } = req.body;
        const prompt = `Rewrite this school notification to be formal, clear, and professional. 
        Provide ONLY one version and include subtle professional emojis (like 📢, 🗓️, 📝) where appropriate.
        Notification: "${text}"`;
        const formalized = await aiService.generateResponse(prompt);
        return success(res, { formalized }, "Text formalized");
    } catch (err) {
        next(err);
    }
};

exports.translate = async (req, res, next) => {
    try {
        const { text, lang } = req.body; // lang: 'telugu' or 'hindi'
        const prompt = `Translate this school notification to ${lang}: "${text}"`;
        const translated = await aiService.generateResponse(prompt);
        return success(res, { translated }, "Text translated");
    } catch (err) {
        next(err);
    }
};

exports.getStats = async (req, res, next) => {
    try {
        const stats = await service.getStats(req.params.id);
        return success(res, stats, "Stats fetched");
    } catch (err) {
        next(err);
    }
};

exports.getMyNotifications = async (req, res, next) => {
    try {
        const userId = req.user.userId;
        const notifications = await service.getNotificationsForUser(userId);
        return success(res, notifications, "Notifications fetched");
    } catch (err) {
        next(err);
    }
};

exports.markRead = async (req, res, next) => {
    try {
        const { id } = req.params;
        const userId = req.user.userId;
        await service.updateStatus(id, userId, 'seen');
        return success(res, null, "Marked as seen");
    } catch (err) {
        next(err);
    }
};

exports.listAll = async (req, res, next) => {
    try {
        const notifications = await service.getAllNotifications();
        return success(res, notifications, "All notifications fetched");
    } catch (err) {
        next(err);
    }
};

exports.delete = async (req, res, next) => {
    try {
        const { id } = req.params;
        await service.deleteNotification(id);
        return success(res, null, "Notification deleted");
    } catch (err) {
        next(err);
    }
};
