-- Row Level Security and tenancy context

-- Assumption: app sets current_setting('app.school_id') and current_setting('app.user_id')
-- via SET LOCAL in connection or via a security definer function.

-- Create trusted settings for tenancy context
do $$ begin
  perform set_config('app.school_id', '', true);
  perform set_config('app.user_id', '', true);
  perform set_config('app.role', '', true); -- principal|teacher|admin|parent
exception when others then null; end $$;

-- Helper: parse UUID from settings
create or replace function app_current_school_id() returns uuid language sql stable parallel safe as $$
  select nullif(current_setting('app.school_id', true), '')::uuid
$$;

create or replace function app_current_user_id() returns uuid language sql stable parallel safe as $$
  select nullif(current_setting('app.user_id', true), '')::uuid
$$;

create or replace function app_current_role() returns text language sql stable parallel safe as $$
  select nullif(current_setting('app.role', true), '')
$$;

-- Enable RLS
alter table "user" enable row level security;
alter table staff_profile enable row level security;
alter table parent_profile enable row level security;
alter table student enable row level security;
alter table student_parent enable row level security;
alter table classroom enable row level security;
alter table enrollment enable row level security;
alter table attendance enable row level security;
alter table assessment enable row level security;
alter table grade enable row level security;
alter table communication enable row level security;
alter table session enable row level security;
alter table audit_log enable row level security;

-- Base policy: tenant isolation by school_id
create policy user_tenant_isolation on "user"
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy staff_profile_tenant on staff_profile
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy parent_profile_tenant on parent_profile
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy student_tenant on student
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy student_parent_tenant on student_parent
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy classroom_tenant on classroom
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy enrollment_tenant on enrollment
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy attendance_tenant on attendance
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy assessment_tenant on assessment
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy grade_tenant on grade
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy communication_tenant on communication
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy session_tenant on session
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

create policy audit_tenant on audit_log
  using (school_id = app_current_school_id())
  with check (school_id = app_current_school_id());

-- Role-based refinement: parents can only see their linked students
create policy student_parent_parent_view on student
  for select using (
    app_current_role() = 'parent' and exists (
      select 1 from student_parent sp
      where sp.school_id = student.school_id
        and sp.student_id = student.id
        and sp.parent_user_id = app_current_user_id()
    )
  );

-- Teachers can see students in their classes via enrollment
create policy student_teacher_view on student
  for select using (
    app_current_role() in ('teacher','principal','admin') and exists (
      select 1 from enrollment e
      join classroom c on c.id = e.class_id and c.school_id = e.school_id
      where e.school_id = student.school_id
        and e.student_id = student.id
        and (c.teacher_user_id = app_current_user_id() or app_current_role() in ('principal','admin'))
    )
  );

-- Grades visibility: parents see only their child's grades; teachers see their classes; admins/principals see all
create policy grade_parent_view on grade
  for select using (
    app_current_role() = 'parent' and exists (
      select 1 from student_parent sp where sp.school_id = grade.school_id
        and sp.student_id = grade.student_id and sp.parent_user_id = app_current_user_id()
    )
  );

create policy grade_teacher_view on grade
  for select using (
    app_current_role() in ('teacher','principal','admin') and exists (
      select 1 from assessment a join classroom c on c.id = a.class_id and c.school_id = a.school_id
      where a.id = grade.assessment_id and (
        c.teacher_user_id = app_current_user_id() or app_current_role() in ('principal','admin')
      )
    )
  );

-- Attendance visibility similarly
create policy attendance_parent_view on attendance
  for select using (
    app_current_role() = 'parent' and exists (
      select 1 from student_parent sp where sp.school_id = attendance.school_id
        and sp.student_id = attendance.student_id and sp.parent_user_id = app_current_user_id()
    )
  );

create policy attendance_teacher_view on attendance
  for select using (
    app_current_role() in ('teacher','principal','admin') and exists (
      select 1 from classroom c where c.id = attendance.class_id and c.school_id = attendance.school_id
        and (c.teacher_user_id = app_current_user_id() or app_current_role() in ('principal','admin'))
    )
  );

-- Write policies: teachers can write attendance and grades for their classes only
create policy attendance_teacher_write on attendance
  for insert with check (
    app_current_role() in ('teacher','principal','admin') and exists (
      select 1 from classroom c where c.id = attendance.class_id and c.school_id = attendance.school_id
        and (c.teacher_user_id = app_current_user_id() or app_current_role() in ('principal','admin'))
    )
  );

create policy grade_teacher_write on grade
  for insert with check (
    app_current_role() in ('teacher','principal','admin') and exists (
      select 1 from assessment a join classroom c on c.id = a.class_id and c.school_id = a.school_id
      where a.id = grade.assessment_id and (
        c.teacher_user_id = app_current_user_id() or app_current_role() in ('principal','admin')
      )
    )
  );

-- Deny by default: rely on RLS enabled and only these policies grant access

