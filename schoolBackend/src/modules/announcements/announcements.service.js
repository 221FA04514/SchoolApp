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
}) => {
  const [result] = await pool.query(
    `
    INSERT INTO announcements (title, description, created_by, role, section_id, scheduled_at, attachment_url)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
    [title, description, created_by, role, section_id, scheduled_at, attachment_url]
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
    SELECT id, title, description, created_at
    FROM announcements
    WHERE created_by = ? AND role = 'teacher'
    ORDER BY created_at DESC
    `,
    [teacherId]
  );
  return rows;
};

/**
 * Student: get all announcements
 */
exports.getAllAnnouncements = async (section_id = null) => {
  let query = `
    SELECT 
      id,
      title,
      description,
      scheduled_at,
      attachment_url,
      created_at
    FROM announcements
    WHERE (scheduled_at IS NULL OR scheduled_at <= NOW())
  `;
  const params = [];

  if (section_id) {
    query += " AND (section_id IS NULL OR section_id = ?)";
    params.push(section_id);
  } else {
    query += " AND section_id IS NULL";
  }

  query += " ORDER BY created_at DESC";

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
      id,
      title,
      description,
      created_at
    FROM announcements
    WHERE id = ?
    `,
    [id]
  );

  return rows[0];
};
