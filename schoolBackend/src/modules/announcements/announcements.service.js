const pool = require("../../config/db");

/**
 * Create announcement (teacher/admin)
 */
exports.createAnnouncement = async ({
  title,
  description,
  created_by,
  role,
  section_id = null,
  scheduled_at = null,
  attachment_url = null,
  deadline = null,
}) => {
  const [result] = await pool.query(
    `
    INSERT INTO announcements (title, description, created_by, role, section_id, scheduled_at, attachment_url, deadline)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `,
    [title, description, created_by, role, section_id, scheduled_at, attachment_url, deadline]
  );

  return {
    id: result.insertId,
    title,
    description,
  };
};

/**
 * Teacher: get own announcements
 */
exports.getTeacherAnnouncements = async (teacherId) => {
  const [rows] = await pool.query(
    `
    SELECT id, title, description, created_at, deadline, role
    FROM announcements
    WHERE (created_by = ? AND role = 'teacher') OR role = 'admin'
    ORDER BY created_at DESC
    `,
    [teacherId]
  );
  return rows;
};

/**
 * Student: get all announcements
 */
exports.getAllAnnouncements = async (section_id = null, userId = null) => {
  let query = `
    SELECT 
      a.id,
      a.title,
      a.description,
      a.scheduled_at,
      a.attachment_url,
      a.created_at,
      a.deadline,
      a.role,
      COALESCE(t.name, 'Administrator') as creator_name
    FROM announcements a
    LEFT JOIN teachers t ON a.created_by = t.user_id
    WHERE (a.scheduled_at IS NULL OR a.scheduled_at <= NOW())
  `;
  const params = [];

  if (section_id) {
    query += " AND (a.section_id IS NULL OR a.section_id = ?)";
    params.push(section_id);
  } else {
    query += " AND a.section_id IS NULL";
  }

  // Exclude announcements the user has dismissed
  if (userId) {
    query += " AND a.id NOT IN (SELECT announcement_id FROM announcement_dismissals WHERE user_id = ?)";
    params.push(userId);
  }

  query += " ORDER BY a.created_at DESC";

  const [rows] = await pool.query(query, params);
  return rows;
};

/**
 * Get single announcement detail
 */
exports.getAnnouncementById = async (id) => {
  const [rows] = await pool.query(
    `
    SELECT 
      a.id,
      a.title,
      a.description,
      a.created_at,
      a.deadline,
      COALESCE(t.name, 'Administrator') as creator_name
    FROM announcements a
    LEFT JOIN teachers t ON a.created_by = t.user_id
    WHERE a.id = ?
    `,
    [id]
  );

  return rows[0];
};

/**
 * Delete announcement (manually by admin/teacher)
 */
exports.deleteAnnouncement = async (id) => {
  // 1. Check if announcement exists
  const [rows] = await pool.query("SELECT id FROM announcements WHERE id = ?", [id]);
  if (rows.length === 0) {
    const err = new Error("Announcement not found");
    err.status = 404;
    throw err;
  }

  await pool.query("DELETE FROM announcements WHERE id = ?", [id]);
  return true;
};

/**
 * Student: dismiss an announcement (hide from their view, not global delete)
 */
exports.dismissAnnouncement = async (announcementId, userId) => {
  await pool.query(
    `INSERT INTO announcement_dismissals (announcement_id, user_id)
     VALUES (?, ?)
     ON CONFLICT (announcement_id, user_id) DO NOTHING`,
    [announcementId, userId]
  );
  return true;
};
