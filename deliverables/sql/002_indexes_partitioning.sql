-- Indexes for common access patterns and login/dashboard speed

-- Users: login by email within a school
create index if not exists idx_user_school_email on "user" (school_id, email);
create index if not exists idx_user_school_lastlogin on "user" (school_id, last_login_at desc);

-- Staff filtered by role
create index if not exists idx_staff_school_role on staff_profile (school_id, role);

-- Students lookup
create index if not exists idx_student_school_name on student (school_id, full_name);
create index if not exists idx_student_school_extnum on student (school_id, external_student_number);

-- Parent linking
create index if not exists idx_student_parent_parent on student_parent (school_id, parent_user_id);
create index if not exists idx_student_parent_student on student_parent (school_id, student_id);

-- Class operations
create index if not exists idx_class_school_teacher on classroom (school_id, teacher_user_id);
create index if not exists idx_enrollment_class on enrollment (school_id, class_id, active);
create index if not exists idx_enrollment_student on enrollment (school_id, student_id, active);

-- Attendance high-volume queries (by class/date and by student/date)
create index if not exists idx_attendance_class_date on attendance (school_id, class_id, class_date);
create index if not exists idx_attendance_student_date on attendance (school_id, student_id, class_date);

-- Assessments and grades
create index if not exists idx_assessment_class on assessment (school_id, class_id, due_date);
create index if not exists idx_grade_assessment_student on grade (school_id, assessment_id, student_id);
create index if not exists idx_grade_student_time on grade (school_id, student_id, graded_at desc);

-- Sessions: purge and validation
create index if not exists idx_session_user_active on session (school_id, user_id, expires_at desc);

-- Audit logs: by actor and time window
create index if not exists idx_audit_school_actor_time on audit_log (school_id, actor_user_id, created_at desc);

-- Optional: BRIN indexes for time-series tables to keep cost low on large datasets
create index if not exists brin_attendance_created_at on attendance using brin (created_at);
create index if not exists brin_grade_graded_at on grade using brin (graded_at);
create index if not exists brin_audit_created_at on audit_log using brin (created_at);

-- Partitioning strategy (by school to isolate data and enable pruning)
-- For PostgreSQL native partitioning, we define partitions for high-volume tables.

-- Attendance partitioning by school_id
-- Note: Requires creating as partitioned from the beginning; else requires table rewrite.
-- For the challenge deliverables, we document the approach via DDL below.

-- Example DDL (to be applied on fresh DB):
-- create table attendance (
--   id uuid primary key default gen_random_uuid(),
--   school_id uuid not null references school(id) on delete cascade,
--   class_id uuid not null references classroom(id) on delete cascade,
--   student_id uuid not null references student(id) on delete cascade,
--   class_date date not null,
--   status text not null check (status in ('present','absent','late','excused')),
--   recorded_by_user_id uuid references "user"(id),
--   created_at timestamptz not null default now(),
--   unique (school_id, class_id, student_id, class_date)
-- ) partition by list (school_id);
-- create table attendance_sch_default partition of attendance default;

-- Similarly for grade and audit_log if needed at 500+ schools scale.

