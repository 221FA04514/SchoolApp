-- SQL Migration Script for Aiven Cloud
-- Apply these changes to fix Foreign Key issues and support Teacher Leaves

-- 1. Fix results table to handle unique constraints properly for Online Exams
-- (Optional: only if you find duplicate result errors)
-- ALTER TABLE results ADD UNIQUE INDEX unique_student_exam_subject (student_id, exam_id, subject);

-- 2. Leave Management Table
-- If the table is missing, create it first
CREATE TABLE IF NOT EXISTS leaves (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,  -- Will store user_id for both students/teachers
    reason TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Ensure student_id column is correctly typed (if table already existed)
ALTER TABLE leaves MODIFY student_id INT NOT NULL;

-- 3. Ensure Announcements table has correct defaults
ALTER TABLE announcements MODIFY section_id INT NULL;
ALTER TABLE announcements MODIFY scheduled_at DATETIME NULL;
ALTER TABLE announcements MODIFY attachment_url VARCHAR(255) NULL;

-- 4. Digital Library Enhancements
-- Increase type column size to avoid truncation for long extensions
ALTER TABLE resources MODIFY type VARCHAR(50) NOT NULL;

-- NOTE: If you get "Duplicate column name 'description'", it means this change is ALREADY applied!
-- You can safely comment out the line below if it errors.
-- ALTER TABLE resources ADD COLUMN description TEXT AFTER title;
