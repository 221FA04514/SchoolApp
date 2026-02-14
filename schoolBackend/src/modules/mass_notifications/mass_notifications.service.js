const pool = require("../../config/db");

exports.createMassNotification = async ({ title, body, attachment_url, created_by, scheduled_at, expires_at, targets }) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        // 1. Create the master notification
        const [notifResult] = await connection.query(
            "INSERT INTO mass_notifications (title, body, attachment_url, created_by, scheduled_at, expires_at) VALUES (?, ?, ?, ?, ?, ?)",
            [title, body, attachment_url, created_by, scheduled_at, expires_at]
        );
        const notifId = notifResult.insertId;

        // 2. Expand targets to user IDs
        let targetUserIds = new Set();

        for (const target of targets) {
<<<<<<< HEAD
            if (target.type === 'role') {
                const [users] = await connection.query("SELECT id FROM users WHERE role = ?", [target.id]);
                users.forEach(u => targetUserIds.add(u.id));
=======
            console.log(`[MassNotif] Processing target: ${JSON.stringify(target)}`);
            if (target.type === 'role') {
                const [users] = await connection.query("SELECT id FROM users WHERE role = ?", [target.id]);
                console.log(`[MassNotif] Found ${users.length} users for role ${target.id}`);
                users.forEach(u => targetUserIds.add(u.id));

                // 2.1 Sync with Announcements Board (For Students/Everyone)
                if (target.id === 'student') {
                    try {
                        console.log(`[MassNotif] Syncing to announcements for student`);
                        await connection.query(
                            "INSERT INTO announcements (title, description, created_by, role, section_id, scheduled_at, attachment_url) VALUES (?, ?, ?, ?, ?, ?, ?)",
                            [title, body, created_by, 'admin', null, scheduled_at, attachment_url || null]
                        );
                        console.log(`[MassNotif] Synced to announcements successfully`);
                    } catch (syncErr) {
                        const fs = require('fs');
                        fs.appendFileSync('error_log.txt', `[MassNotif] Announcement Sync Error: ${syncErr.message}\n`);
                        console.error(`[MassNotif] Announcement Sync Error:`, syncErr);
                        // Do not rethrow, so notification still sends
                    }
                }
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
            } else if (target.type === 'section') {
                const [users] = await connection.query(
                    "SELECT user_id FROM students WHERE section_id = ? UNION SELECT user_id FROM teachers t JOIN teacher_subject_mappings m ON t.id = m.teacher_id WHERE m.section_id = ?",
                    [target.id, target.id]
                );
                users.forEach(u => targetUserIds.add(u.user_id));
            } else if (target.type === 'group' && target.id === 'fee_defaulters') {
                const [users] = await connection.query(
                    "SELECT u.id FROM users u JOIN students s ON u.id = s.user_id LEFT JOIN fee_payments fp ON s.id = fp.student_id WHERE fp.id IS NULL OR fp.status != 'paid'"
                );
                users.forEach(u => targetUserIds.add(u.id));
            } else if (target.type === 'individual') {
                targetUserIds.add(target.id);
            }
        }

<<<<<<< HEAD
=======
        console.log(`[MassNotif] Total unique targets: ${targetUserIds.size}`);

>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        // 3. Create receipts
        if (targetUserIds.size > 0) {
            const values = Array.from(targetUserIds).map(uid => [notifId, uid]);
            await connection.query(
                "INSERT INTO notification_receipts (notification_id, user_id) VALUES ?",
                [values]
            );
<<<<<<< HEAD
=======
            console.log(`[MassNotif] Receipts inserted for ${values.length} users`);

            // 4. Emit Real-time Socket Events
            const { sendNotification } = require("../../config/socket");
            targetUserIds.forEach(uid => {
                sendNotification(uid, {
                    title,
                    message: body,
                    type: 'admin',
                    created_at: new Date().toISOString()
                });
            });
        } else {
            console.warn(`[MassNotif] No users found for targets`);
>>>>>>> 719d44b (Fix: Remove Quizzes module and update API configuration)
        }

        await connection.commit();
        return notifId;
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};

exports.getStats = async (notificationId) => {
    const [rows] = await pool.query(
        "SELECT status, COUNT(*) as count FROM notification_receipts WHERE notification_id = ? GROUP BY status",
        [notificationId]
    );
    return rows;
};

exports.getNotificationsForUser = async (userId) => {
    const [rows] = await pool.query(`
        SELECT mn.*, nr.status as receipt_status
        FROM mass_notifications mn
        JOIN notification_receipts nr ON mn.id = nr.notification_id
        WHERE nr.user_id = ? 
        AND (mn.expires_at IS NULL OR mn.expires_at > CURRENT_TIMESTAMP)
        ORDER BY mn.created_at DESC
    `, [userId]);
    return rows;
};

exports.updateStatus = async (notificationId, userId, status) => {
    await pool.query(
        "UPDATE notification_receipts SET status = ? WHERE notification_id = ? AND user_id = ?",
        [status, notificationId, userId]
    );
};

exports.getAllNotifications = async () => {
    const [rows] = await pool.query("SELECT * FROM mass_notifications ORDER BY created_at DESC");
    return rows;
};

exports.deleteNotification = async (id) => {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();
        await connection.query("DELETE FROM notification_receipts WHERE notification_id = ?", [id]);
        await connection.query("DELETE FROM mass_notifications WHERE id = ?", [id]);
        await connection.commit();
    } catch (err) {
        await connection.rollback();
        throw err;
    } finally {
        connection.release();
    }
};
