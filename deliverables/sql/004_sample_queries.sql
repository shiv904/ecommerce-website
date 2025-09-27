-- Assumes app sets app.school_id, app.user_id, app.role

-- Teacher dashboard: classes taught and today attendance summary
with my_classes as (
  select c.id as class_id, c.name, c.section, c.academic_year
  from classroom c
  where c.school_id = app_current_school_id()
    and c.teacher_user_id = app_current_user_id()
), today_att as (
  select a.class_id,
         sum(case when a.status='present' then 1 else 0 end) as present,
         sum(case when a.status='absent' then 1 else 0 end) as absent,
         sum(case when a.status='late' then 1 else 0 end) as late
  from attendance a
  where a.school_id = app_current_school_id()
    and a.class_date = current_date
    and exists (select 1 from my_classes m where m.class_id = a.class_id)
  group by a.class_id
)
select m.class_id, m.name, coalesce(t.present,0) as present,
       coalesce(t.absent,0) as absent, coalesce(t.late,0) as late
from my_classes m
left join today_att t on t.class_id = m.class_id
order by m.name;

-- Parent mobile: latest grades and recent attendance for my child
-- Input: :student_id from parent's linked students
select g.assessment_id, g.score, g.graded_at, a.title, a.category
from grade g
join assessment a on a.id = g.assessment_id and a.school_id = g.school_id
where g.school_id = app_current_school_id()
  and g.student_id = :student_id
order by g.graded_at desc
limit 20;

select a.class_date, a.status, a.class_id
from attendance a
where a.school_id = app_current_school_id()
  and a.student_id = :student_id
  and a.class_date >= current_date - interval '14 days'
order by a.class_date desc;

