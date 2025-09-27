-- Minimal seed data for demo
-- Fixed UUIDs for deterministic demo

-- School
insert into school (id, name, code, timezone)
values ('11111111-1111-1111-1111-111111111111', 'Demo School', 'SCH1', 'UTC')
on conflict (id) do nothing;

-- Users
insert into "user" (id, school_id, email, password_hash, user_kind, mfa_enabled)
values 
  ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'teacher@demo.edu', 'argon2$dummy', 'staff', false),
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'parent@demo.edu',  'argon2$dummy', 'parent', false)
on conflict (id) do nothing;

-- Profiles
insert into staff_profile (user_id, school_id, role, full_name)
values ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'teacher', 'Taylor Teacher')
on conflict (user_id) do nothing;

insert into parent_profile (user_id, school_id, full_name)
values ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Pat Parent')
on conflict (user_id) do nothing;

-- Student
insert into student (id, school_id, external_student_number, full_name, dob, gender)
values ('44444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'STU-001', 'Alex Student', '2012-05-10', 'other')
on conflict (id) do nothing;

-- Parent link
insert into student_parent (school_id, student_id, parent_user_id, relationship)
values ('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'guardian')
on conflict do nothing;

-- Classroom
insert into classroom (id, school_id, name, subject, grade_level, section, academic_year, teacher_user_id)
values ('55555555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'Math A', 'Mathematics', 'Grade 7', 'A', '2025-2026', '22222222-2222-2222-2222-222222222222')
on conflict (id) do nothing;

-- Enrollment
insert into enrollment (id, school_id, class_id, student_id, enrolled_on, active)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', current_date, true)
on conflict (id) do nothing;

-- Attendance today
insert into attendance (id, school_id, class_id, student_id, class_date, status, recorded_by_user_id)
values ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', current_date, 'present', '22222222-2222-2222-2222-222222222222')
on conflict (id) do nothing;

-- Assessment and grade
insert into assessment (id, school_id, class_id, title, category, max_score, due_date, weight_percent)
values ('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', 'Quiz 1', 'quiz', 100, current_date, 10)
on conflict (id) do nothing;

insert into grade (id, school_id, assessment_id, student_id, score, graded_by_user_id)
values ('77777777-7777-7777-7777-777777777777', '11111111-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', 85, '22222222-2222-2222-2222-222222222222')
on conflict (id) do nothing;

