-- StudentTracker logical schema for PostgreSQL
-- Multitenant by `school_id` with RLS-ready design

create extension if not exists pgcrypto;

-- Tenancy anchor
create table if not exists school (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    code text not null unique,
    timezone text not null default 'UTC',
    created_at timestamptz not null default now()
);

-- Users and profiles
create table if not exists "user" (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    email citext not null,
    password_hash text not null,
    user_kind text not null check (user_kind in ('staff','parent')),
    mfa_enabled boolean not null default false,
    last_login_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (school_id, email)
);

create table if not exists staff_profile (
    user_id uuid primary key references "user"(id) on delete cascade,
    school_id uuid not null references school(id) on delete cascade,
    role text not null check (role in ('principal','teacher','admin')),
    full_name text not null
);

create table if not exists parent_profile (
    user_id uuid primary key references "user"(id) on delete cascade,
    school_id uuid not null references school(id) on delete cascade,
    full_name text not null,
    phone_encrypted bytea,
    address_encrypted bytea,
    encryption_key_id text
);

-- Students
create table if not exists student (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    external_student_number text,
    full_name text not null,
    dob date,
    gender text,
    personal_info_encrypted bytea,
    encryption_key_id text,
    created_at timestamptz not null default now()
);

create table if not exists student_parent (
    school_id uuid not null references school(id) on delete cascade,
    student_id uuid not null references student(id) on delete cascade,
    parent_user_id uuid not null references "user"(id) on delete cascade,
    relationship text not null check (relationship in ('mother','father','guardian','other')),
    linked_at timestamptz not null default now(),
    primary key (school_id, student_id, parent_user_id)
);

-- Classes and enrollment
create table if not exists classroom (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    name text not null,
    subject text,
    grade_level text,
    section text,
    academic_year text not null,
    teacher_user_id uuid references "user"(id) on delete set null,
    created_at timestamptz not null default now()
);

create table if not exists enrollment (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    class_id uuid not null references classroom(id) on delete cascade,
    student_id uuid not null references student(id) on delete cascade,
    enrolled_on date not null default current_date,
    active boolean not null default true,
    unique (school_id, class_id, student_id)
);

-- Attendance (high write volume)
create table if not exists attendance (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    class_id uuid not null references classroom(id) on delete cascade,
    student_id uuid not null references student(id) on delete cascade,
    class_date date not null,
    status text not null check (status in ('present','absent','late','excused')),
    recorded_by_user_id uuid references "user"(id),
    created_at timestamptz not null default now(),
    unique (school_id, class_id, student_id, class_date)
);

-- Assessments and grades
create table if not exists assessment (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    class_id uuid not null references classroom(id) on delete cascade,
    title text not null,
    category text not null check (category in ('test','quiz','assignment','exam','project')),
    max_score numeric(10,2) not null,
    due_date date,
    weight_percent numeric(5,2),
    created_at timestamptz not null default now()
);

create table if not exists grade (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    assessment_id uuid not null references assessment(id) on delete cascade,
    student_id uuid not null references student(id) on delete cascade,
    score numeric(10,2) not null,
    graded_at timestamptz not null default now(),
    graded_by_user_id uuid references "user"(id),
    unique (school_id, assessment_id, student_id)
);

-- Communications, sessions, audit logs
create table if not exists communication (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    to_parent_user_id uuid references "user"(id),
    from_user_id uuid references "user"(id),
    channel text not null check (channel in ('sms','email','push','call')),
    subject text,
    message_excerpt text,
    sent_at timestamptz not null default now()
);

create table if not exists session (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    user_id uuid not null references "user"(id) on delete cascade,
    jwt_id text,
    created_at timestamptz not null default now(),
    expires_at timestamptz not null,
    ip inet,
    user_agent text
);

create table if not exists audit_log (
    id uuid primary key default gen_random_uuid(),
    school_id uuid not null references school(id) on delete cascade,
    actor_user_id uuid references "user"(id),
    action text not null,
    resource_type text not null,
    resource_id uuid,
    details jsonb,
    created_at timestamptz not null default now()
);

