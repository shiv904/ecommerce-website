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

