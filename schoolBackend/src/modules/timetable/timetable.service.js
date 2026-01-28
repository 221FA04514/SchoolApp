const pool = require("../../config/db");

/**
 * Check if a teacher is already busy at a specific time
 */
exports.checkTeacherConflict = async (teacherName, day, period, excludeSectionId = null) => {
  const [rows] = await pool.query(
    "SELECT section_id FROM timetable WHERE teacher_name = ? AND day = ? AND period = ? AND section_id != ?",
    [teacherName, day, period, excludeSectionId ?? -1]
  );
  return rows.length > 0;
};

/**
 * Check if a section already has a slot at a specific time
 */
exports.checkSectionConflict = async (sectionId, day, period) => {
  const [rows] = await pool.query(
    "SELECT id FROM timetable WHERE section_id = ? AND day = ? AND period = ?",
    [sectionId, day, period]
  );
  return rows.length > 0;
};

/**
 * Get all teachers NOT busy in this period
 */
exports.getAvailableTeachers = async (day, period) => {
  const [rows] = await pool.query(
    `SELECT name FROM teachers WHERE name NOT IN (
      SELECT teacher_name FROM timetable WHERE day = ? AND period = ?
    )`,
    [day, period]
  );
  return rows.map(r => r.name);
};

/**
 * Teacher: create or update timetable slot
 */
exports.upsertTimetable = async ({
  section_id,
  day,
  period,
  subject,
  teacher_name,
  start_time,
  end_time,
  force = false,
}) => {
  // 1. Check for section conflict (Always block this, as one period can't have two classes in one section)
  const hasSectionConflict = await exports.checkSectionConflict(section_id, day, period);
  if (hasSectionConflict && !force) {
    const err = new Error(`Section already has a slot assigned for ${day}, Period ${period}`);
    err.status = 409;
    throw err;
  }

  // 2. Check for teacher conflict in ANY section
  const hasTeacherConflict = await exports.checkTeacherConflict(teacher_name, day, period);
  if (hasTeacherConflict && !force) {
    const available = await exports.getAvailableTeachers(day, period);
    const err = new Error(`Teacher '${teacher_name}' is already assigned elsewhere in Period ${period}.`);
    err.status = 409;
    err.suggestions = available.slice(0, 5); // Sugggest first 5 free teachers
    throw err;
  }

  await pool.query(
    `
    INSERT INTO timetable
      (section_id, day, period, subject, teacher_name, start_time, end_time)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    `,
    [
      section_id,
      day,
      period,
      subject,
      teacher_name,
      start_time,
      end_time,
    ]
  );
};

/**
 * Teacher: get timetable for a section
 */
exports.getTimetableBySection = async (sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT id, day, period, subject, teacher_name, start_time, end_time
    FROM timetable
    WHERE section_id = ?
    ORDER BY FIELD(day,
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
    ), period
    `,
    [sectionId]
  );

  return rows;
};

/**
 * Teacher: get personal timetable
 */
exports.getTeacherPersonalTimetable = async (userId) => {
  // First, get teacher name from teachers table
  const [[teacher]] = await pool.query("SELECT name FROM teachers WHERE user_id = ?", [userId]);
  if (!teacher) return [];

  const [rows] = await pool.query(
    `
    SELECT id, day, period, subject, teacher_name, start_time, end_time, section_id
    FROM timetable
    WHERE teacher_name = ?
    ORDER BY FIELD(day,
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
    ), period
    `,
    [teacher.name]
  );

  return rows;
};

/**
 * Student: get timetable (section-wise)
 */
exports.getStudentTimetable = async (sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT id, day, period, subject, teacher_name, start_time, end_time
    FROM timetable
    WHERE section_id = ?
    ORDER BY FIELD(day,
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'
    ), period
    `,
    [sectionId]
  );

  return rows;
};
/**
 * Delete a timetable slot
 */
exports.deleteTimetableSlot = async (id) => {
  await pool.query("DELETE FROM timetable WHERE id = ?", [id]);
};
