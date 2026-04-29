-- Create archived_timetables table
CREATE TABLE IF NOT EXISTS "archived_timetables" (
  "id" SERIAL PRIMARY KEY,
  "original_id" INTEGER,
  "section_id" INTEGER NOT NULL,
  "day" VARCHAR(50) NOT NULL,
  "period" INTEGER NOT NULL,
  "subject" varchar(50) NOT NULL,
  "teacher_name" varchar(100) NOT NULL,
  "start_time" time NOT NULL,
  "end_time" time NOT NULL,
  "archived_at" timestamp DEFAULT CURRENT_TIMESTAMP,
  "snapshot_tag" varchar(100),
  CONSTRAINT "fk_archived_section" FOREIGN KEY ("section_id") REFERENCES "sections" ("id") ON DELETE CASCADE
);

-- Ensure period_settings columns are correct types (casting if necessary)
-- Note: If they are already varchar, we might need to handle transformation
-- For now, let's keep it safe.

-- Clear current timetable (as requested for a fresh start)
-- TRUNCATE "timetable"; -- We will do this via the Archive logic in Node.js instead to be safe.
