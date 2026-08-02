-- ============================================
-- Training Progress & Interests Tables
-- Version: 1.0.1
-- Created: 2026-08-02
-- ============================================

-- ============================================
-- PLAYER INTERESTS TABLE
-- Stores user's interests selected during onboarding
-- ============================================
CREATE TABLE IF NOT EXISTS player_interests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    interests TEXT[] DEFAULT '{}' CHECK (
        interests <@ ARRAY['draw', 'position', 'bank', 'kick', 'jump', 'masse', 'safety', '3cushion', 'trickshot', 'break']
    ),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(player_id)
);

CREATE INDEX idx_player_interests_player_id ON player_interests(player_id);

-- ============================================
-- DRILL PROGRESS TABLE
-- Tracks user's progress through drill levels
-- ============================================
CREATE TABLE IF NOT EXISTS drill_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    drill_code TEXT NOT NULL,
    current_level INTEGER DEFAULT 1 CHECK (current_level BETWEEN 1 AND 5),
    best_score INTEGER DEFAULT 0 CHECK (best_score BETWEEN 0 AND 100),
    total_attempts INTEGER DEFAULT 0,
    total_successes INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(player_id, drill_code)
);

CREATE INDEX idx_drill_progress_player_id ON drill_progress(player_id);
CREATE INDEX idx_drill_progress_drill_code ON drill_progress(drill_code);

-- ============================================
-- DRILL LEVEL ATTEMPTS TABLE
-- Records individual level attempts
-- ============================================
CREATE TABLE IF NOT EXISTS drill_level_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    drill_code TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    attempts INTEGER NOT NULL,
    successes INTEGER NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    passed BOOLEAN DEFAULT FALSE,
    attempted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_drill_level_attempts_player_id ON drill_level_attempts(player_id);
CREATE INDEX idx_drill_level_attempts_drill_code ON drill_level_attempts(drill_code);
CREATE INDEX idx_drill_level_attempts_level ON drill_level_attempts(level);

-- ============================================
-- TRIGGER: Update updated_at
-- ============================================
CREATE TRIGGER update_drill_progress_updated_at
    BEFORE UPDATE ON drill_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE player_interests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own interests" ON player_interests
    FOR ALL USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

ALTER TABLE drill_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own drill progress" ON drill_progress
    FOR ALL USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

ALTER TABLE drill_level_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own level attempts" ON drill_level_attempts
    FOR ALL USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

-- ============================================
-- SEED DATA: Drill Levels
-- ============================================
CREATE TABLE IF NOT EXISTS drill_levels (
    id SERIAL PRIMARY KEY,
    drill_code TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    target_attempts INTEGER DEFAULT 10,
    pass_count INTEGER DEFAULT 8,
    difficulty_param TEXT,
    description TEXT,
    UNIQUE(drill_code, level)
);

-- Insert drill levels for all drills
INSERT INTO drill_levels (drill_code, level, target_attempts, pass_count, description)
SELECT * FROM (
    VALUES
    ('STRAIGHT_POT', 1, 10, 8, '20cm distance'),
    ('STRAIGHT_POT', 2, 10, 8, '30cm distance'),
    ('STRAIGHT_POT', 3, 10, 8, '50cm distance'),
    ('STRAIGHT_POT', 4, 10, 8, '70cm distance'),
    ('STRAIGHT_POT', 5, 10, 9, 'Full table distance'),
    ('DRAW_SHOT', 1, 10, 6, '20cm draw'),
    ('DRAW_SHOT', 2, 10, 7, '40cm draw'),
    ('DRAW_SHOT', 3, 10, 8, '60cm draw'),
    ('DRAW_SHOT', 4, 10, 8, '80cm draw'),
    ('DRAW_SHOT', 5, 10, 9, '1m+ draw'),
    ('FOLLOW_SHOT', 1, 10, 6, '30cm follow'),
    ('FOLLOW_SHOT', 2, 10, 7, '50cm follow'),
    ('FOLLOW_SHOT', 3, 10, 8, '80cm follow'),
    ('FOLLOW_SHOT', 4, 10, 8, '1m follow'),
    ('FOLLOW_SHOT', 5, 10, 9, 'Full table follow'),
    ('STOP_BALL', 1, 10, 6, '20cm stop'),
    ('STOP_BALL', 2, 10, 7, '15cm stop'),
    ('STOP_BALL', 3, 10, 8, '10cm stop'),
    ('STOP_BALL', 4, 10, 8, '5cm stop'),
    ('STOP_BALL', 5, 10, 9, '2cm stop'),
    ('BANK_SHOT', 1, 10, 4, 'Basic bank'),
    ('BANK_SHOT', 2, 10, 5, 'Medium bank'),
    ('BANK_SHOT', 3, 10, 6, 'Hard bank'),
    ('BANK_SHOT', 4, 10, 7, 'Advanced bank'),
    ('BANK_SHOT', 5, 10, 8, 'Expert bank'),
    ('KICK_SHOT', 1, 10, 2, 'Basic kick'),
    ('KICK_SHOT', 2, 10, 3, 'Medium kick'),
    ('KICK_SHOT', 3, 10, 4, 'Hard kick'),
    ('KICK_SHOT', 4, 10, 5, 'Advanced kick'),
    ('KICK_SHOT', 5, 10, 6, 'Expert kick'),
    ('JUMP_SHOT', 1, 10, 2, 'Basic jump'),
    ('JUMP_SHOT', 2, 10, 2, 'Medium jump'),
    ('JUMP_SHOT', 3, 10, 3, 'Hard jump'),
    ('JUMP_SHOT', 4, 10, 4, 'Advanced jump'),
    ('JUMP_SHOT', 5, 10, 5, 'Expert jump')
) AS t(drill_code, level, target_attempts, pass_count, description)
ON CONFLICT (drill_code, level) DO NOTHING;
