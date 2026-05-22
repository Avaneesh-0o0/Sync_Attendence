-- =========================================
-- STEP 1: CLEAN RESET (Drop All Public Tables)
-- =========================================

DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;


-- =========================================
-- STEP 2: USERS TABLE
-- =========================================

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  name text not null,
  role text check (role in ('student', 'teacher')),
  department text,
  avatar_url text,
  created_at timestamp with time zone default now()
);

-- Enable RLS on users table
alter table public.users enable row level security;

-- Create policies for users table
create policy "Users can view their own profile"
  on public.users for select
  using ( auth.uid() = id );

create policy "Users can insert their own profile"
  on public.users for insert
  with check ( auth.uid() = id );

create policy "Users can update their own profile"
  on public.users for update
  using ( auth.uid() = id );


-- =========================================
-- STEP 2.5: AUTH TRIGGER FOR NEW USERS
-- =========================================

-- Function to handle new user registration
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'role'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user registration
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- =========================================
-- STEP 3: CLASSES TABLE
-- =========================================

create table public.classes (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  subject_code text,
  semester text default 'Current',
  department text,
  teacher_id uuid references public.users(id) on delete set null,
  total_students integer default 50,
  created_at timestamp with time zone default now()
);


-- =========================================
-- STEP 4: STUDENTS TABLE
-- =========================================

create table public.students (
  user_id uuid primary key references public.users(id) on delete cascade,
  roll_no text not null,
  class_id uuid references public.classes(id) on delete set null,
  created_at timestamp with time zone default now()
);


-- =========================================
-- STEP 5: SESSIONS TABLE
-- =========================================

create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references public.users(id) on delete cascade,
  class_id uuid not null references public.classes(id) on delete cascade,
  subject text,
  mode text not null check (mode in ('QR', 'BLE', 'HYBRID')),
  start_time timestamp with time zone default now(),
  end_time timestamp with time zone,
  is_active boolean default true,
  created_at timestamp with time zone default now()
);


-- =========================================
-- STEP 6: ATTENDANCE TABLE
-- =========================================

create table public.attendance (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  student_id uuid not null references public.students(user_id) on delete cascade,
  marked_at timestamp with time zone default now(),
  device_id text,
  verification_method text,
  student_name text,
  roll_number text,
  status text default 'present',
  synced boolean default false,
  constraint unique_attendance unique (session_id, student_id)
);


-- =========================================
-- STEP 7: PERFORMANCE INDEXES
-- =========================================

create index idx_attendance_session on public.attendance(session_id);
create index idx_attendance_student on public.attendance(student_id);
create index idx_sessions_class on public.sessions(class_id);
create index idx_sessions_teacher on public.sessions(teacher_id);
create index idx_students_class on public.students(class_id);


-- =========================================
-- STEP 8: MIGRATION — Add missing columns to existing attendance table
-- Run this in Supabase SQL Editor if you already have the table created
-- =========================================

ALTER TABLE public.attendance
  ADD COLUMN IF NOT EXISTS verification_method text,
  ADD COLUMN IF NOT EXISTS student_name text,
  ADD COLUMN IF NOT EXISTS roll_number text,
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'present',
  ADD COLUMN IF NOT EXISTS synced boolean DEFAULT false;

-- =========================================
-- STEP 9: DYNAMIC QR & ATTENDANCE RPC
-- =========================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE OR REPLACE FUNCTION public.mark_attendance_qr(
  p_session_id uuid,
  p_token text,
  p_student_id uuid,
  p_method text,
  p_student_name text,
  p_roll_number text,
  p_synced boolean
)
RETURNS text AS $$
DECLARE
  v_secret text := 'attendix_secret_key_2026';
  v_parts text[];
  v_qr_session text;
  v_window_id text;
  v_hash text;
  v_computed_hash text;
  v_time_now bigint;
BEGIN
  -- Validate token
  v_parts := string_to_array(p_token, ':');
  IF array_length(v_parts, 1) != 4 OR v_parts[1] != 'ATTENDIX_QR' THEN 
    RETURN 'INVALID_FORMAT'; 
  END IF;

  v_qr_session := v_parts[2];
  v_window_id := v_parts[3];
  v_hash := v_parts[4];

  IF v_qr_session != p_session_id::text THEN 
    RETURN 'SESSION_MISMATCH'; 
  END IF;
  
  -- Check window validity (4-window grace period = ~120 seconds)
  -- This accounts for clock drift between teacher device and server
  v_time_now := cast(extract(epoch from now()) as bigint) / 30;
  IF abs(v_time_now - cast(v_window_id as bigint)) > 4 THEN 
    RETURN 'EXPIRED'; 
  END IF;
  
  -- Re-compute hash
  v_computed_hash := substring(encode(digest(v_qr_session || v_window_id || v_secret, 'sha256'), 'hex') from 1 for 8);
  IF v_computed_hash != v_hash THEN 
    RETURN 'INVALID_SIGNATURE'; 
  END IF;

  -- Validation passed, Mark attendance
  INSERT INTO public.attendance (
    session_id, student_id, verification_method, 
    student_name, roll_number, status, synced, marked_at
  )
  VALUES (
    p_session_id, p_student_id, p_method, 
    p_student_name, p_roll_number, 'present', p_synced, now()
  )
  ON CONFLICT ON CONSTRAINT unique_attendance DO NOTHING;

  RETURN 'SUCCESS';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
