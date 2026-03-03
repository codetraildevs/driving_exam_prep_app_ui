/*
  # Create Core Tables for Traffic Rules Learning App

  1. New Tables
    - `users` - User profiles and statistics
      - `id` (uuid, primary key) - User ID from auth
      - `name` (text) - Full name
      - `email` (text) - Email address
      - `avatar_url` (text) - Avatar image URL
      - `daily_streak` (integer) - Current streak count
      - `last_login` (timestamp) - Last login date
      - `created_at` (timestamp) - Account creation date
      - `updated_at` (timestamp) - Last update

    - `traffic_signs` - Traffic sign database
      - `id` (uuid, primary key)
      - `title` (text) - Sign title
      - `description` (text) - Detailed description
      - `category` (text) - Type: Warning, Regulatory, Informational
      - `image_url` (text) - Sign image URL
      - `scenario` (text) - Real-life scenario example
      - `created_at` (timestamp)

    - `categories` - Practice categories
      - `id` (uuid, primary key)
      - `name` (text) - Category name
      - `type` (text) - Category type
      - `icon` (text) - Icon name
      - `created_at` (timestamp)

    - `questions` - Quiz questions
      - `id` (uuid, primary key)
      - `text` (text) - Question text
      - `category_id` (uuid, foreign key)
      - `difficulty` (text) - Easy, Medium, Hard
      - `correct_answer` (text) - Correct answer
      - `explanation` (text) - Why the answer is correct
      - `created_at` (timestamp)

    - `answers` - Answer options for questions
      - `id` (uuid, primary key)
      - `question_id` (uuid, foreign key)
      - `text` (text) - Answer text
      - `is_correct` (boolean) - Is this the correct answer
      - `explanation` (text) - Explanation if wrong
      - `created_at` (timestamp)

    - `user_progress` - Track learned signs
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `sign_id` (uuid, foreign key)
      - `is_learned` (boolean)
      - `learned_at` (timestamp)
      - `created_at` (timestamp)

    - `exam_attempts` - Track exam sessions
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `score` (integer) - Score out of 100
      - `total_questions` (integer)
      - `correct_answers` (integer)
      - `accuracy` (decimal) - Percentage accuracy
      - `passed` (boolean) - Pass/fail status
      - `duration_seconds` (integer) - Exam duration
      - `completed_at` (timestamp)
      - `created_at` (timestamp)

    - `user_answers` - Individual answers in exams
      - `id` (uuid, primary key)
      - `attempt_id` (uuid, foreign key)
      - `question_id` (uuid, foreign key)
      - `selected_answer` (text)
      - `is_correct` (boolean)
      - `created_at` (timestamp)

    - `badges` - Achievement badges
      - `id` (uuid, primary key)
      - `name` (text) - Badge name
      - `description` (text) - Badge description
      - `icon` (text) - Icon emoji or name
      - `criteria` (text) - How to earn badge
      - `created_at` (timestamp)

    - `user_badges` - Earned badges
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key)
      - `badge_id` (uuid, foreign key)
      - `earned_at` (timestamp)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Users can only see their own data
    - Public read access for traffic signs and questions
*/

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT,
  daily_streak INTEGER DEFAULT 0,
  last_login TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Traffic signs table
CREATE TABLE IF NOT EXISTS traffic_signs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  scenario TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE traffic_signs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view traffic signs"
  ON traffic_signs FOR SELECT
  TO authenticated
  USING (true);

-- Categories table
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

-- Questions table
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text TEXT NOT NULL,
  category_id UUID REFERENCES categories(id),
  difficulty TEXT DEFAULT 'medium',
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view questions"
  ON questions FOR SELECT
  TO authenticated
  USING (true);

-- Answers table
CREATE TABLE IF NOT EXISTS answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT false,
  explanation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view answers"
  ON answers FOR SELECT
  TO authenticated
  USING (true);

-- User progress table
CREATE TABLE IF NOT EXISTS user_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  sign_id UUID NOT NULL REFERENCES traffic_signs(id) ON DELETE CASCADE,
  is_learned BOOLEAN DEFAULT false,
  learned_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, sign_id)
);

ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress"
  ON user_progress FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON user_progress FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can modify own progress"
  ON user_progress FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Exam attempts table
CREATE TABLE IF NOT EXISTS exam_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER NOT NULL,
  accuracy DECIMAL(5, 2) NOT NULL,
  passed BOOLEAN NOT NULL,
  duration_seconds INTEGER,
  completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE exam_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own exam attempts"
  ON exam_attempts FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create exam attempts"
  ON exam_attempts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- User answers table
CREATE TABLE IF NOT EXISTS user_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES exam_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  selected_answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE user_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own answers"
  ON user_answers FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM exam_attempts
      WHERE exam_attempts.id = user_answers.attempt_id
      AND exam_attempts.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create answers"
  ON user_answers FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM exam_attempts
      WHERE exam_attempts.id = user_answers.attempt_id
      AND exam_attempts.user_id = auth.uid()
    )
  );

-- Badges table
CREATE TABLE IF NOT EXISTS badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  criteria TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view badges"
  ON badges FOR SELECT
  TO authenticated
  USING (true);

-- User badges table
CREATE TABLE IF NOT EXISTS user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES badges(id),
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own badges"
  ON user_badges FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can earn badges"
  ON user_badges FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_sign_id ON user_progress(sign_id);
CREATE INDEX IF NOT EXISTS idx_exam_attempts_user_id ON exam_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_exam_attempts_completed_at ON exam_attempts(completed_at);
CREATE INDEX IF NOT EXISTS idx_user_answers_attempt_id ON user_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_questions_category_id ON questions(category_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_user_id ON user_badges(user_id);
