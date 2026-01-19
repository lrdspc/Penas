-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela: users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  user_type TEXT CHECK (user_type IN ('trainer', 'student')) NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  profile_photo_url TEXT,
  status TEXT CHECK (status IN ('active', 'inactive')) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_login TIMESTAMPTZ
);

-- Índices
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_last_login ON users(last_login);

-- RLS Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Trainers can view their students"
  ON users FOR SELECT
  USING (
    user_type = 'student' AND
    EXISTS (
      SELECT 1 FROM trainer_students
      WHERE trainer_id = auth.uid()
      AND student_id = id
      AND status = 'active'
    )
  );

-- Tabela: trainer_students
CREATE TABLE trainer_students (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  invite_token TEXT UNIQUE NOT NULL,
  invite_expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '24 hours'),
  invited_at TIMESTAMPTZ DEFAULT now(),
  accepted_at TIMESTAMPTZ,
  status TEXT CHECK (status IN ('pending', 'active', 'inactive')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  last_interaction TIMESTAMPTZ,
  UNIQUE(trainer_id, student_id)
);

-- Índices
CREATE INDEX idx_trainer_students_trainer_id ON trainer_students(trainer_id);
CREATE INDEX idx_trainer_students_student_id ON trainer_students(student_id);
CREATE INDEX idx_trainer_students_invite_token ON trainer_students(invite_token);
CREATE INDEX idx_trainer_students_status ON trainer_students(status);
CREATE INDEX idx_trainer_students_invite_expires ON trainer_students(invite_expires_at);

-- RLS Policies
ALTER TABLE trainer_students ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trainers can manage their students"
  ON trainer_students FOR ALL
  USING (
    trainer_id = auth.uid() OR
    student_id = auth.uid()
  );

-- Tabela: exercises
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  muscle_groups TEXT[] NOT NULL, -- Array: ARRAY['peito', 'triceps']
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
  video_url TEXT,
  image_url TEXT,
  video_storage_path TEXT, -- Para Supabase Storage
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  views_count INT DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0.0
);

-- Índices
CREATE INDEX idx_exercises_trainer_id ON exercises(trainer_id);
CREATE INDEX idx_exercises_muscle_groups ON exercises USING GIN(muscle_groups);
CREATE INDEX idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX idx_exercises_name ON exercises(name);

-- RLS Policies
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trainers can manage their exercises"
  ON exercises FOR ALL
  USING (trainer_id = auth.uid());

CREATE POLICY "Students can view trainer exercises"
  ON exercises FOR SELECT
  USING (
    trainer_id IN (
      SELECT trainer_id
      FROM trainer_students
      WHERE student_id = auth.uid()
      AND status = 'active'
    )
  );

-- Tabela: workouts
CREATE TABLE workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  workout_type TEXT CHECK (workout_type IN ('strength', 'cardio', 'hiit', 'functional', 'mobility')) NOT NULL DEFAULT 'strength',
  estimated_duration_minutes INT,
  is_template BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_used TIMESTAMPTZ
);

-- Índices
CREATE INDEX idx_workouts_trainer_id ON workouts(trainer_id);
CREATE INDEX idx_workouts_is_template ON workouts(is_template);
CREATE INDEX idx_workouts_workout_type ON workouts(workout_type);
CREATE INDEX idx_workouts_last_used ON workouts(last_used);

-- RLS Policies
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trainers can manage their workouts"
  ON workouts FOR ALL
  USING (trainer_id = auth.uid());

CREATE POLICY "Students can view assigned workouts"
  ON workouts FOR SELECT
  USING (
    id IN (
      SELECT workout_id
      FROM student_workouts
      WHERE student_id = auth.uid()
      AND status IN ('pending', 'in_progress', 'completed')
    )
  );

-- Tabela: workout_exercises
CREATE TABLE workout_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES exercises(id) NOT NULL,
  order_num INT NOT NULL,
  sets INT NOT NULL CHECK (sets BETWEEN 1 AND 10),
  reps INT NOT NULL CHECK (reps BETWEEN 1 AND 100),
  rest_seconds INT DEFAULT 60 CHECK (rest_seconds BETWEEN 15 AND 300),
  weight_kg DECIMAL(6,2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices
CREATE INDEX idx_workout_exercises_workout_id ON workout_exercises(workout_id);
CREATE INDEX idx_workout_exercises_exercise_id ON workout_exercises(exercise_id);
CREATE INDEX idx_workout_exercises_order_num ON workout_exercises(order_num);

-- RLS Policies
ALTER TABLE workout_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Access via workout"
  ON workout_exercises FOR SELECT
  USING (
    workout_id IN (
      SELECT id FROM workouts
      WHERE trainer_id = auth.uid()
      OR id IN (
        SELECT workout_id FROM student_workouts
        WHERE student_id = auth.uid()
      )
    )
  );

-- Tabela: student_workouts
CREATE TABLE student_workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  workout_id UUID REFERENCES workouts(id) NOT NULL,
  assigned_date DATE NOT NULL,
  completed_date TIMESTAMPTZ,
  status TEXT CHECK (status IN ('pending', 'in_progress', 'completed', 'abandoned', 'skipped')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  scheduled_time TIME,
  notes TEXT
);

-- Índices
CREATE INDEX idx_student_workouts_student_id ON student_workouts(student_id);
CREATE INDEX idx_student_workouts_workout_id ON student_workouts(workout_id);
CREATE INDEX idx_student_workouts_assigned_date ON student_workouts(assigned_date);
CREATE INDEX idx_student_workouts_status ON student_workouts(status);
CREATE INDEX idx_student_workouts_scheduled_time ON student_workouts(scheduled_time);

-- RLS Policies
ALTER TABLE student_workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can view their workouts"
  ON student_workouts FOR SELECT
  USING (
    student_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM trainer_students
      WHERE trainer_id = auth.uid()
      AND student_id = student_workouts.student_id
      AND status = 'active'
    )
  );

CREATE POLICY "Students can update their progress"
  ON student_workouts FOR UPDATE
  USING (student_id = auth.uid());

CREATE POLICY "Trainers can assign workouts"
  ON student_workouts FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM trainer_students
      WHERE trainer_id = auth.uid()
      AND student_id = student_id
      AND status = 'active'
    ) AND
    workout_id IN (
      SELECT id FROM workouts
      WHERE trainer_id = auth.uid()
    )
  );

-- Tabela: workout_sessions
CREATE TABLE workout_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_workout_id UUID REFERENCES student_workouts(id) ON DELETE SET NULL,
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  total_duration_seconds INT,
  status TEXT CHECK (status IN ('in_progress', 'completed', 'abandoned')) DEFAULT 'in_progress',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  offline_mode BOOLEAN DEFAULT false,
  sync_status TEXT CHECK (sync_status IN ('pending', 'synced', 'failed')) DEFAULT 'pending',
  device_info TEXT
);

-- Índices
CREATE INDEX idx_workout_sessions_student_id ON workout_sessions(student_id);
CREATE INDEX idx_workout_sessions_student_workout_id ON workout_sessions(student_workout_id);
CREATE INDEX idx_workout_sessions_started_at ON workout_sessions(started_at);
CREATE INDEX idx_workout_sessions_status ON workout_sessions(status);
CREATE INDEX idx_workout_sessions_sync_status ON workout_sessions(sync_status);

-- RLS Policies
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Students can manage their sessions"
  ON workout_sessions FOR ALL
  USING (student_id = auth.uid());

CREATE POLICY "Trainers can view student sessions"
  ON workout_sessions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM trainer_students
      WHERE trainer_id = auth.uid()
      AND student_id = workout_sessions.student_id
      AND status = 'active'
    )
  );

-- Tabela: session_exercises
CREATE TABLE session_exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_session_id UUID REFERENCES workout_sessions(id) ON DELETE CASCADE NOT NULL,
  exercise_id UUID REFERENCES exercises(id),
  workout_exercise_id UUID REFERENCES workout_exercises(id),
  order_num INT NOT NULL,
  sets_completed INT NOT NULL CHECK (sets_completed >= 0),
  reps_per_set INT[] NOT NULL, -- Array: ARRAY[10, 10, 9, 10]
  weight_kg DECIMAL(6,2),
  weight_used DECIMAL(6,2),
  notes TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices
CREATE INDEX idx_session_exercises_workout_session_id ON session_exercises(workout_session_id);
CREATE INDEX idx_session_exercises_exercise_id ON session_exercises(exercise_id);
CREATE INDEX idx_session_exercises_order_num ON session_exercises(order_num);
CREATE INDEX idx_session_exercises_sets_completed ON session_exercises(sets_completed);

-- RLS Policies
ALTER TABLE session_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Access via session"
  ON session_exercises FOR ALL
  USING (
    workout_session_id IN (
      SELECT id FROM workout_sessions
      WHERE student_id = auth.uid()
    )
  );

-- Tabela: assessments (Avaliações Físicas)
CREATE TABLE assessments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  trainer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  assessment_date DATE NOT NULL DEFAULT CURRENT_DATE,
  height_cm DECIMAL(5,2),
  weight_kg DECIMAL(6,2),
  body_fat_percent DECIMAL(5,2),
  muscle_mass_percent DECIMAL(5,2),
  chest_cm DECIMAL(6,2),
  waist_cm DECIMAL(6,2),
  hip_cm DECIMAL(6,2),
  left_arm_cm DECIMAL(6,2),
  right_arm_cm DECIMAL(6,2),
  left_leg_cm DECIMAL(6,2),
  right_leg_cm DECIMAL(6,2),
  calf_cm DECIMAL(6,2),
  notes TEXT,
  photos_urls TEXT[],
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Índices
CREATE INDEX idx_assessments_trainer_id ON assessments(trainer_id);
CREATE INDEX idx_assessments_student_id ON assessments(student_id);
CREATE INDEX idx_assessments_date ON assessments(assessment_date);
CREATE INDEX idx_assessments_created_at ON assessments(created_at);

-- RLS Policies
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Trainers and students can access assessments"
  ON assessments FOR ALL
  USING (
    trainer_id = auth.uid() OR
    student_id = auth.uid()
  );

-- Tabela: push_subscriptions (Para Web Push)
CREATE TABLE push_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  subscription JSONB NOT NULL, -- {"endpoint": "", "keys": {"p256dh": "", "auth": ""}}
  user_agent TEXT,
  platform TEXT CHECK (platform IN ('android', 'ios', 'windows', 'macos', 'linux')) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  last_used TIMESTAMPTZ,
  UNIQUE(user_id, subscription->>'endpoint')
);

-- Índices
CREATE INDEX idx_push_subscriptions_user_id ON push_subscriptions(user_id);
CREATE INDEX idx_push_subscriptions_platform ON push_subscriptions(platform);
CREATE INDEX idx_push_subscriptions_last_used ON push_subscriptions(last_used);

-- RLS Policies
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own subscriptions"
  ON push_subscriptions FOR ALL
  USING (user_id = auth.uid());

-- Tabela: offline_sync_queue (Para Background Sync)
CREATE TABLE offline_sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('create_session', 'update_session', 'create_assessment', 'update_workout_status')),
  table_name TEXT NOT NULL,
  record_id UUID,
  payload JSONB NOT NULL,
  status TEXT CHECK (status IN ('pending', 'syncing', 'synced', 'failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  synced_at TIMESTAMPTZ,
  retry_count INT DEFAULT 0,
  last_error TEXT
);

-- Índices
CREATE INDEX idx_sync_queue_user_id ON offline_sync_queue(user_id);
CREATE INDEX idx_sync_queue_status ON offline_sync_queue(status);
CREATE INDEX idx_sync_queue_created_at ON offline_sync_queue(created_at);
CREATE INDEX idx_sync_queue_retry_count ON offline_sync_queue(retry_count);

-- RLS Policies
ALTER TABLE offline_sync_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own queue"
  ON offline_sync_queue FOR ALL
  USING (user_id = auth.uid());
