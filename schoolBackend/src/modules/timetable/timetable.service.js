const pool = require("../../config/db");

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
}) => {
  await pool.query(
    `
    INSERT INTO timetable
      (section_id, day, period, subject, teacher_name, start_time, end_time)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      subject = VALUES(subject),
      teacher_name = VALUES(teacher_name),
      start_time = VALUES(start_time),
      end_time = VALUES(end_time)
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
    SELECT day, period, subject, teacher_name, start_time, end_time
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
 * Student: get timetable (section-wise)
 */
exports.getStudentTimetable = async (sectionId) => {
  const [rows] = await pool.query(
    `
    SELECT day, period, subject, teacher_name, start_time, end_time
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
