-- ============================================
-- PoolOS_v2 Database Schema
-- Version: 1.0.0
-- Created: 2026-08-02
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PLAYERS TABLE
-- Core user/player information
-- ============================================
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT,
    avatar_url TEXT,
    phone TEXT,

    -- Playing Info
    dominant_hand TEXT CHECK (dominant_hand IN ('left', 'right')) DEFAULT 'right',
    current_level TEXT DEFAULT 'beginner' CHECK (current_level IN ('beginner', 'K', 'I', 'H', 'G', 'F')),
    target_level TEXT CHECK (target_level IN ('beginner', 'K', 'I', 'H', 'G', 'F')),
    playing_style TEXT[] DEFAULT '{}',
    years_playing INTEGER DEFAULT 0,
    hours_per_week DECIMAL(5,2) DEFAULT 0,

    -- Goals
    short_term_goal TEXT,
    long_term_goal TEXT,

    -- Meta
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- PLAYER EVENTS TABLE
-- Timeline events for player journey
-- ============================================
CREATE TABLE IF NOT EXISTS player_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL CHECK (event_type IN (
        'level_up', 'achievement', 'first_session', 'milestone',
        'tournament_win', 'streak', 'personal_best', 'onboarding_complete'
    )),
    event_data JSONB DEFAULT '{}',
    event_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_player_events_player_id ON player_events(player_id);
CREATE INDEX idx_player_events_event_date ON player_events(event_date);

-- ============================================
-- SESSIONS TABLE
-- Playing session records
-- ============================================
CREATE TABLE IF NOT EXISTS sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    type TEXT NOT NULL CHECK (type IN ('practice', 'tournament', 'casual')),

    -- Pre-Match Context
    arrival_time TIMESTAMPTZ,
    warmup_duration INTEGER, -- minutes
    warmup_drills TEXT[] DEFAULT '{}',
    warmup_score INTEGER CHECK (warmup_score BETWEEN 1 AND 10),
    match_purpose TEXT,
    opponent_type TEXT,
    table_condition TEXT CHECK (table_condition IN ('familiar', 'unfamiliar')),

    -- Readiness (1-5)
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5) DEFAULT 3,
    focus_level INTEGER CHECK (focus_level BETWEEN 1 AND 5) DEFAULT 3,
    confidence_level INTEGER CHECK (confidence_level BETWEEN 1 AND 5) DEFAULT 3,

    -- Post-Match Context
    fatigue_level TEXT CHECK (fatigue_level IN ('none', 'light', 'moderate', 'heavy')),
    fatigue_locations TEXT[] DEFAULT '{}',
    mental_state TEXT CHECK (mental_state IN ('very_confident', 'confident', 'normal', 'uncertain', 'pressured')),
    self_rating INTEGER CHECK (self_rating BETWEEN 1 AND 5),
    key_factor TEXT,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),

    -- Meta
    duration_minutes INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sessions_player_id ON sessions(player_id);
CREATE INDEX idx_sessions_date ON sessions(date);
CREATE INDEX idx_sessions_status ON sessions(status);

-- ============================================
-- MATCHES TABLE
-- Individual match records within a session
-- ============================================
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    opponent TEXT,
    race_to INTEGER NOT NULL DEFAULT 1,
    result TEXT NOT NULL CHECK (result IN ('win', 'lose', 'draw')),
    match_type TEXT DEFAULT 'friendly' CHECK (match_type IN ('practice', 'friendly', 'tournament', 'league')),
    opponent_level TEXT CHECK (opponent_level IN ('weaker', 'equal', 'stronger')),
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,

    -- Table context
    table_condition TEXT CHECK (table_condition IN ('familiar', 'unfamiliar')),
    environment TEXT CHECK (environment IN ('home', 'club', 'tournament')),
    lighting TEXT CHECK (lighting IN ('good', 'normal', 'poor')),

    -- Score
    player_score INTEGER DEFAULT 0,
    opponent_score INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_matches_session_id ON matches(session_id);

-- ============================================
-- RACKS TABLE
-- Individual rack/frame within a match
-- ============================================
CREATE TABLE IF NOT EXISTS racks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    rack_number INTEGER NOT NULL,
    result TEXT NOT NULL CHECK (result IN ('win', 'lose')),

    -- Break
    break_shot BOOLEAN DEFAULT FALSE,
    break_success BOOLEAN,
    balls_potted_on_break INTEGER DEFAULT 0,

    -- Performance
    longest_run INTEGER DEFAULT 0,
    total_balls_potted INTEGER DEFAULT 0,
    safety_plays INTEGER DEFAULT 0,
    fouls INTEGER DEFAULT 0,

    -- Analysis
    how_won TEXT CHECK (how_won IN ('break_run', 'run_out', 'opponent_error', 'safety_win', 'other')),
    biggest_mistake TEXT,
    biggest_strength TEXT,

    -- Confidence at rack end (1-5)
    confidence INTEGER CHECK (confidence BETWEEN 1 AND 5) DEFAULT 3,

    -- Notes
    note TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_racks_match_id ON racks(match_id);

-- ============================================
-- SHOTS TABLE
-- Individual shots within a rack
-- ============================================
CREATE TABLE IF NOT EXISTS shots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    rack_id UUID NOT NULL REFERENCES racks(id) ON DELETE CASCADE,

    -- Shot type
    shot_type TEXT NOT NULL CHECK (shot_type IN ('pot', 'safety', 'break', 'jump', 'kick', 'bank', 'combo', 'push_out', 'masse')),
    difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard')),

    -- Spin used
    spin_used TEXT[] DEFAULT '{}' CHECK (
        spin_used <@ ARRAY['top', 'back', 'left', 'right', 'follow', 'draw']
    ),

    -- Result
    result TEXT NOT NULL CHECK (result IN ('made', 'missed')),

    -- Events/Mistakes
    events TEXT[] DEFAULT '{}' CHECK (
        events <@ ARRAY[
            'scratch', 'foul', 'double_kiss', 'jumped_cue',
            'easy_miss', 'wrong_angle', 'wrong_speed', 'wrong_spin',
            'bridge_unstable', 'aim_error', 'deceleration', 'kick', 'bad_roll'
        ]
    ),

    -- Confidence before shot (1-10)
    confidence INTEGER CHECK (confidence BETWEEN 1 AND 10) DEFAULT 5,

    -- Practice mode
    challenge TEXT,

    -- Order within rack
    shot_order INTEGER DEFAULT 1,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shots_rack_id ON shots(rack_id);

-- ============================================
-- COACH RECOMMENDATIONS TABLE
-- AI-generated recommendations
-- ============================================
CREATE TABLE IF NOT EXISTS coach_recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,

    -- Insight components
    observation TEXT NOT NULL,
    evidence JSONB DEFAULT '{}',
    reason TEXT,
    data_confidence INTEGER CHECK (data_confidence BETWEEN 0 AND 100),

    -- Action
    recommendation TEXT NOT NULL,
    expected_result TEXT,
    drill_suggestions TEXT[] DEFAULT '{}',

    -- Navigation
    action_label TEXT,
    action_route TEXT,

    -- Priority & Status
    priority TEXT DEFAULT 'improvement' CHECK (priority IN ('critical', 'blocking', 'improvement', 'knowledge', 'positive')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'ignored', 'expired')),

    -- Tracking
    created_at TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_recommendations_player_id ON coach_recommendations(player_id);
CREATE INDEX idx_recommendations_status ON coach_recommendations(status);
CREATE INDEX idx_recommendations_priority ON coach_recommendations(priority);

-- ============================================
-- GOALS TABLE
-- Player goals and targets
-- ============================================
CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    goal_type TEXT CHECK (goal_type IN ('skill', 'tournament', 'session', 'streak', 'custom')),
    target_value DECIMAL,
    current_value DECIMAL DEFAULT 0,
    unit TEXT,
    deadline DATE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_goals_player_id ON goals(player_id);
CREATE INDEX idx_goals_status ON goals(status);

-- ============================================
-- ACHIEVEMENTS TABLE
-- Unlocked achievements and badges
-- ============================================
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    achievement_type TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon_url TEXT,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

CREATE INDEX idx_achievements_player_id ON achievements(player_id);

-- ============================================
-- EQUIPMENT TABLE
-- Player's pool equipment
-- ============================================
CREATE TABLE IF NOT EXISTS equipment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('cue', 'shaft', 'tip', 'chalk', 'glove', 'case', 'other')),
    brand TEXT,
    model TEXT,
    cue_type TEXT CHECK (cue_type IN ('breaking', 'jumping', 'regular', 'snooker')),
    purchase_date DATE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_equipment_player_id ON equipment(player_id);

-- ============================================
-- TRAINING SESSIONS TABLE
-- Dedicated training/practice drills
-- ============================================
CREATE TABLE IF NOT EXISTS training_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    notes TEXT
);

CREATE INDEX idx_training_sessions_player_id ON training_sessions(player_id);

-- ============================================
-- DRILL RUNS TABLE
-- Individual drill attempts
-- ============================================
CREATE TABLE IF NOT EXISTS drill_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES training_sessions(id) ON DELETE CASCADE,
    drill_code TEXT NOT NULL,
    drill_name TEXT NOT NULL,
    category TEXT,
    target_reps INTEGER,
    attempts INTEGER DEFAULT 0,
    successes INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE WHEN attempts > 0 THEN (successes::DECIMAL / attempts::DECIMAL) * 100 ELSE 0 END
    ) STORED,
    duration_seconds INTEGER,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_drill_runs_session_id ON drill_runs(session_id);
CREATE INDEX idx_drill_runs_drill_code ON drill_runs(drill_code);

-- ============================================
-- CUSTOM DRILLS TABLE
-- Player-created custom drills
-- ============================================
CREATE TABLE IF NOT EXISTS custom_drills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT,
    target_reps INTEGER,
    success_criteria TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- DRILL FAVORITES TABLE
-- Player's favorited drills
-- ============================================
CREATE TABLE IF NOT EXISTS drill_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    drill_key TEXT NOT NULL,
    drill_name TEXT NOT NULL,
    category TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(player_id, drill_key)
);

-- ============================================
-- TOURNAMENTS TABLE
-- Tournament participation records
-- ============================================
CREATE TABLE IF NOT EXISTS tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    tournament_type TEXT CHECK (tournament_type IN ('local', 'regional', 'national', 'international', 'online')),
    start_date DATE,
    end_date DATE,
    venue TEXT,
    result TEXT,
    position INTEGER,
    prize_money DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tournaments_player_id ON tournaments(player_id);

-- ============================================
-- CLUBS TABLE
-- Pool clubs
-- ============================================
CREATE TABLE IF NOT EXISTS clubs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    logo_url TEXT,
    venue TEXT,
    address TEXT,
    description TEXT,
    website TEXT,
    admin_id UUID REFERENCES players(id),
    is_verified BOOLEAN DEFAULT FALSE,
    member_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- CLUB MEMBERS TABLE
-- Club membership
-- ============================================
CREATE TABLE IF NOT EXISTS club_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'moderator', 'member', 'guest')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    left_at TIMESTAMPTZ,
    UNIQUE(club_id, player_id)
);

CREATE INDEX idx_club_members_club_id ON club_members(club_id);
CREATE INDEX idx_club_members_player_id ON club_members(player_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
CREATE TRIGGER update_players_updated_at
    BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at
    BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at
    BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_racks_updated_at
    BEFORE UPDATE ON racks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_equipment_updated_at
    BEFORE UPDATE ON equipment
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE player_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE racks ENABLE ROW LEVEL SECURITY;
ALTER TABLE shots ENABLE ROW LEVEL SECURITY;
ALTER TABLE coach_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_drills ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE club_members ENABLE ROW LEVEL SECURITY;

-- Players: Users can only see/edit their own data
CREATE POLICY "Users can view own profile" ON players
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON players
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON players
    FOR UPDATE USING (auth.uid() = user_id);

-- Player Events: Own data only
CREATE POLICY "Users can view own events" ON player_events
    FOR SELECT USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can insert own events" ON player_events
    FOR INSERT WITH CHECK (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

-- Sessions: Own data only
CREATE POLICY "Users can view own sessions" ON sessions
    FOR SELECT USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can insert own sessions" ON sessions
    FOR INSERT WITH CHECK (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can update own sessions" ON sessions
    FOR UPDATE USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can delete own sessions" ON sessions
    FOR DELETE USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

-- Matches: Cascade from sessions
CREATE POLICY "Users can view own matches" ON matches
    FOR SELECT USING (
        session_id IN (SELECT id FROM sessions WHERE player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
    );

CREATE POLICY "Users can insert own matches" ON matches
    FOR INSERT WITH CHECK (
        session_id IN (SELECT id FROM sessions WHERE player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
    );

CREATE POLICY "Users can update own matches" ON matches
    FOR UPDATE USING (
        session_id IN (SELECT id FROM sessions WHERE player_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
    );

-- Racks: Cascade from matches
CREATE POLICY "Users can view own racks" ON racks
    FOR SELECT USING (
        match_id IN (
            SELECT m.id FROM matches m
            JOIN sessions s ON m.session_id = s.id
            JOIN players p ON s.player_id = p.id
            WHERE p.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own racks" ON racks
    FOR INSERT WITH CHECK (
        match_id IN (
            SELECT m.id FROM matches m
            JOIN sessions s ON m.session_id = s.id
            JOIN players p ON s.player_id = p.id
            WHERE p.user_id = auth.uid()
        )
    );

-- Shots: Cascade from racks
CREATE POLICY "Users can view own shots" ON shots
    FOR SELECT USING (
        rack_id IN (
            SELECT r.id FROM racks r
            JOIN matches m ON r.match_id = m.id
            JOIN sessions s ON m.session_id = s.id
            JOIN players p ON s.player_id = p.id
            WHERE p.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own shots" ON shots
    FOR INSERT WITH CHECK (
        rack_id IN (
            SELECT r.id FROM racks r
            JOIN matches m ON r.match_id = m.id
            JOIN sessions s ON m.session_id = s.id
            JOIN players p ON s.player_id = p.id
            WHERE p.user_id = auth.uid()
        )
    );

-- Coach Recommendations: Own data only
CREATE POLICY "Users can view own recommendations" ON coach_recommendations
    FOR SELECT USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

CREATE POLICY "Users can update own recommendations" ON coach_recommendations
    FOR UPDATE USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Goals: Own data only
CREATE POLICY "Users can manage own goals" ON goals
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Achievements: Own data only
CREATE POLICY "Users can view own achievements" ON achievements
    FOR SELECT USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Equipment: Own data only
CREATE POLICY "Users can manage own equipment" ON equipment
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Training Sessions: Own data only
CREATE POLICY "Users can manage own training" ON training_sessions
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Drill Runs: Cascade from training sessions
CREATE POLICY "Users can manage own drill runs" ON drill_runs
    FOR ALL USING (
        session_id IN (
            SELECT id FROM training_sessions
            WHERE player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
        )
    );

-- Custom Drills: Own data only
CREATE POLICY "Users can manage own custom drills" ON custom_drills
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Drill Favorites: Own data only
CREATE POLICY "Users can manage own drill favorites" ON drill_favorites
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Tournaments: Own data only
CREATE POLICY "Users can manage own tournaments" ON tournaments
    FOR ALL USING (player_id IN (SELECT id FROM players WHERE user_id = auth.uid()));

-- Clubs: Public read, manage via club_members
CREATE POLICY "Anyone can view clubs" ON clubs
    FOR SELECT USING (true);

CREATE POLICY "Players can create clubs" ON clubs
    FOR INSERT WITH CHECK (
        admin_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

-- Club Members: Own membership
CREATE POLICY "Members can view club members" ON club_members
    FOR SELECT USING (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid()) OR
        club_id IN (SELECT id FROM clubs WHERE admin_id IN (SELECT id FROM players WHERE user_id = auth.uid()))
    );

CREATE POLICY "Players can join clubs" ON club_members
    FOR INSERT WITH CHECK (
        player_id IN (SELECT id FROM players WHERE user_id = auth.uid())
    );

-- ============================================
-- VIEWS FOR ANALYTICS
-- ============================================

-- Player statistics view
CREATE OR REPLACE VIEW player_stats AS
SELECT
    p.id AS player_id,
    p.current_level,
    COUNT(DISTINCT s.id) AS total_sessions,
    COUNT(DISTINCT m.id) AS total_matches,
    SUM(CASE WHEN m.result = 'win' THEN 1 ELSE 0 END) AS wins,
    SUM(CASE WHEN m.result = 'lose' THEN 1 ELSE 0 END) AS losses,
    COALESCE(
        ROUND(
            CAST(SUM(CASE WHEN m.result = 'win' THEN 1 ELSE 0 END) AS DECIMAL) /
            NULLIF(COUNT(m.id), 0) * 100,
            1
        ),
        0
    ) AS win_rate,
    COUNT(DISTINCT sh.id) AS total_shots,
    SUM(CASE WHEN sh.result = 'made' THEN 1 ELSE 0 END) AS shots_made,
    COALESCE(
        ROUND(
            CAST(SUM(CASE WHEN sh.result = 'made' THEN 1 ELSE 0 END) AS DECIMAL) /
            NULLIF(COUNT(sh.id), 0) * 100,
            1
        ),
        0
    ) AS shot_accuracy
FROM players p
LEFT JOIN sessions s ON p.id = s.player_id AND s.status = 'completed'
LEFT JOIN matches m ON s.id = m.session_id
LEFT JOIN racks r ON m.id = r.match_id
LEFT JOIN shots sh ON r.id = sh.rack_id
GROUP BY p.id, p.current_level;

-- ============================================
-- SEED DATA: Drills Library
-- ============================================
CREATE TABLE IF NOT EXISTS drills_library (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    name_vi TEXT NOT NULL,
    name_en TEXT,
    category TEXT NOT NULL,
    difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    description_vi TEXT,
    target_reps INTEGER DEFAULT 10,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert basic drills
INSERT INTO drills_library (code, name_vi, name_en, category, difficulty, description_vi) VALUES
-- Basic Shots
('POT_STRAIGHT', 'Đánh thẳng', 'Straight Pot', 'shots', 'beginner', 'Đánh bóng vào lỗ từ khoảng cách gần'),
('POT_ANGLE', 'Đánh góc', 'Angle Pot', 'shots', 'beginner', 'Đánh bóng vào lỗ với góc nghiêng'),
('FOLLOW_SHOT', 'Follow', 'Follow Shot', 'shots', 'beginner', 'Đánh bóng đi sau bi mục tiêu'),
('DRAW_SHOT', 'Draw', 'Draw Shot', 'shots', 'intermediate', 'Đánh bóng quay về sau khi chạm bi'),
('BANKS', 'Bank', 'Bank Shot', 'shots', 'intermediate', 'Đánh bóng bằng cách chạm băng'),
('KICK_SHOT', 'Kick', 'Kick Shot', 'shots', 'advanced', 'Đánh bóng bằng cách đá từ băng'),
('JUMP_SHOT', 'Jump', 'Jump Shot', 'shots', 'advanced', 'Nhảy qua chướng ngại vật'),

-- Position
('POSITION_STRAIGHT', 'Kiểm soát vị trí thẳng', 'Straight Position', 'position', 'beginner', 'Dừng bi tại vị trí mong muốn'),
('POSITION_CUT', 'Kiểm soát vị trí cắt', 'Cut Position', 'position', 'intermediate', 'Kiểm soát vị trí sau cú cắt'),
('POSITION_SPIN', 'Kiểm soát vị trí xoáy', 'Spin Position', 'position', 'advanced', 'Dùng xoáy để kiểm soát vị trí'),

-- Safety
('SAFETY_BASIC', 'An toàn cơ bản', 'Basic Safety', 'safety', 'beginner', 'Đánh an toàn không để đối thủ dễ đánh'),
('SAFETY_FORCE', 'An toàn ép lực', 'Force Safety', 'safety', 'intermediate', 'Buộc đối thủ đánh khó'),
('SAFETY_PINCH', 'An toàn kẹp', 'Pinching Safety', 'safety', 'advanced', 'Kẹp bi đối thủ vào băng'),

-- Break
('BREAK_POWER', 'Khai cuộc lực mạnh', 'Power Break', 'break', 'beginner', 'Khai cuộc với lực mạnh'),
('BREAK_CONTROL', 'Khai cuộc kiểm soát', 'Control Break', 'break', 'intermediate', 'Khai cuộc kiểm soát'),
('BREAK_SPREAD', 'Khai cuộc phết', 'Spread Break', 'break', 'advanced', 'Khai cuộc phết bóng đều'),

-- Advanced
('MASSÉ', 'Masse', 'Masse', 'advanced', 'advanced', 'Đánh xoáy ngược'),
('SNAKE', 'Snake', 'Snake Shot', 'advanced', 'advanced', 'Đánh bóng theo đường cong')
ON CONFLICT (code) DO NOTHING;
