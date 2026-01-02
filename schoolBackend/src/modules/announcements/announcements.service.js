const pool = require("../../config/db");

/**
 * Get all announcements (for student list screen)
 */
exports.getAllAnnouncements = async () => {
  const [rows] = await pool.query(`
    SELECT 
      id,
      title,
      description,
      created_at
    FROM announcements
    ORDER BY created_at DESC
  `);

  return rows;
};

exports.createAnnouncement = async (data) => {
  const { title, description, created_by, role } = data;

  const [result] = await pool.query(
    `
    INSERT INTO announcements (title, description, created_by, role)
    VALUES (?, ?, ?, ?)
    `,
    [title, description, created_by, role]
  );

  return {
    id: result.insertId,
    title,
    description,
  };
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
