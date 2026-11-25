-- Add additional international exam languages to courses.examType enum.
ALTER TABLE courses
  MODIFY COLUMN examType ENUM('kinyarwanda','english','french','swahili','arabic')
  NOT NULL DEFAULT 'english';
