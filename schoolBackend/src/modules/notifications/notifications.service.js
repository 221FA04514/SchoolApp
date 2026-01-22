const pool = require("../../config/db");
const { sendNotification } = require("../../config/socket");

exports.createNotification = async (userId, title, body, type = 'general') => {
    try {
        const [result] = await pool.query(
            "INSERT INTO notifications (user_id, title, body, type) VALUES (?, ?, ?, ?)",
            [userId, title, body, type]
        );

        const newNotif = {
            id: result.insertId,
            title,
            body,
            type,
            is_read: false,
            created_at: new Date()
        };

        // Push live via Socket
        sendNotification(userId, newNotif);

        return newNotif;
    } catch (err) {
        console.error("Error creating notification:", err.message);
        throw err;
    }
};

exports.getUserNotifications = async (userId) => {
    const [rows] = await pool.query(
        "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50",
        [userId]
    );
    return rows;
};

exports.markAsRead = async (notifId) => {
    await pool.query("UPDATE notifications SET is_read = TRUE WHERE id = ?", [notifId]);
};
