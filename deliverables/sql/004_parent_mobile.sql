-- Parent mobile: latest grades and recent attendance for my child
-- Provide :student_id via psql \set student_id 'uuid'

\echo '--- Parent latest grades ---'
select g.assessment_id, g.score, g.graded_at, a.title, a.category
from grade g
join assessment a on a.id = g.assessment_id and a.school_id = g.school_id
where g.school_id = app_current_school_id()
  and g.student_id = (select :'student_id'::uuid)
order by g.graded_at desc
limit 20;

\echo '--- Parent recent attendance (14 days) ---'
select a.class_date, a.status, a.class_id
from attendance a
where a.school_id = app_current_school_id()
  and a.student_id = (select :'student_id'::uuid)
  and a.class_date >= current_date - interval '14 days'
order by a.class_date desc;

