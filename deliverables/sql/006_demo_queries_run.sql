-- Demo: run teacher and parent queries with RLS context

-- Teacher context
begin;
select set_config('app.school_id','11111111-1111-1111-1111-111111111111', true);
select set_config('app.user_id','22222222-2222-2222-2222-222222222222', true);
select set_config('app.role','teacher', true);
\echo '--- Teacher dashboard: today attendance summary ---'
\i /workspace/deliverables/sql/004_teacher_dashboard.sql
commit;

-- Parent context
begin;
select set_config('app.school_id','11111111-1111-1111-1111-111111111111', true);
select set_config('app.user_id','33333333-3333-3333-3333-333333333333', true);
select set_config('app.role','parent', true);
\set student_id '44444444-4444-4444-4444-444444444444'
\i /workspace/deliverables/sql/004_parent_mobile.sql
commit;