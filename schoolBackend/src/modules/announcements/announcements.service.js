const pool = require("../../config/db");

/**
 * Create announcement (teacher/admin)
 */
exports.createAnnouncement = async ({
  title,
  description,
  created_by,
  role,
}) => {
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
