-- ============================================================
-- MY STUDIO APP — Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── INSTRUCTORS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS instructors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  specialty TEXT,
  active BOOLEAN DEFAULT true
);

-- ── ROOMS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  capacity INT DEFAULT 12
);

-- ── CLIENTS ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS clients (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  date_of_birth DATE,
  experience_level TEXT DEFAULT 'beginner',
  injuries TEXT,
  emergency_contact TEXT,
  onboarding_completed BOOLEAN DEFAULT false,
  health_declaration_signed BOOLEAN DEFAULT false,
  waiver_signed BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── MEMBERSHIP PLANS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS membership_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  duration_days INT NOT NULL DEFAULT 30,
  sessions_limit INT, -- NULL = unlimited
  description TEXT,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── CLIENT MEMBERSHIPS ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS client_memberships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES membership_plans(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status TEXT DEFAULT 'active', -- active, expired, cancelled
  auto_renew BOOLEAN DEFAULT true,
  sessions_used INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── CLASS SESSIONS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS class_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT DEFAULT 'yoga', -- yoga, pilates
  instructor_id UUID REFERENCES instructors(id),
  room_id UUID REFERENCES rooms(id),
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  max_capacity INT DEFAULT 12,
  level TEXT DEFAULT 'all',
  status TEXT DEFAULT 'scheduled', -- scheduled, cancelled, completed
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── BOOKINGS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  session_id UUID REFERENCES class_sessions(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'confirmed', -- confirmed, cancelled, attended, no_show
  booked_at TIMESTAMPTZ DEFAULT NOW(),
  cancelled_at TIMESTAMPTZ,
  UNIQUE(client_id, session_id)
);

-- ── PAYMENTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES clients(id),
  membership_id UUID REFERENCES client_memberships(id),
  amount NUMERIC(10,2) NOT NULL,
  method TEXT DEFAULT 'card', -- card, cash, transfer, bit
  status TEXT DEFAULT 'paid',  -- paid, pending, refunded
  description TEXT,
  payment_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── NOTIFICATIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info', -- reminder, alert, payment, info
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DISABLE ROW LEVEL SECURITY (personal app, no auth needed)
-- ============================================================
ALTER TABLE instructors         DISABLE ROW LEVEL SECURITY;
ALTER TABLE rooms               DISABLE ROW LEVEL SECURITY;
ALTER TABLE clients             DISABLE ROW LEVEL SECURITY;
ALTER TABLE membership_plans    DISABLE ROW LEVEL SECURITY;
ALTER TABLE client_memberships  DISABLE ROW LEVEL SECURITY;
ALTER TABLE class_sessions      DISABLE ROW LEVEL SECURITY;
ALTER TABLE bookings            DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments            DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications       DISABLE ROW LEVEL SECURITY;

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO instructors (name, specialty) VALUES
  ('דנה כהן', 'פילאטיס'),
  ('מאיה לוי', 'יוגה'),
  ('נועה ברון', 'יין יוגה')
ON CONFLICT DO NOTHING;

INSERT INTO rooms (name, capacity) VALUES
  ('אולם א', 12),
  ('אולם ב', 8)
ON CONFLICT DO NOTHING;

INSERT INTO membership_plans (name, price, duration_days, sessions_limit, description) VALUES
  ('חודשי ללא הגבלה', 390, 30, NULL,  'כל השיעורים כלולים'),
  ('כרטיסייה 10 כניסות', 350, 90, 10, '10 כניסות, תקף 3 חודשים'),
  ('כניסה בודדת', 60, 1, 1,           'כניסה חד פעמית')
ON CONFLICT DO NOTHING;

-- Demo client
INSERT INTO clients (name, phone, email, experience_level, onboarding_completed, health_declaration_signed, waiver_signed)
VALUES ('שירה כהן', '054-1234567', 'shira@example.com', 'intermediate', true, true, true)
ON CONFLICT DO NOTHING;
