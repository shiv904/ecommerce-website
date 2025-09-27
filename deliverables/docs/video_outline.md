### Video Outline (5–10 minutes)

1) Problem and Goals (0:30)
- Slow login/data, scalability to 500+ schools, strict privacy.

2) Schema Overview (2:00)
- Walk through `school`, `user` + profiles, `student`, `classroom`, `enrollment`, `attendance`, `assessment`, `grade`, `communication`, `session`, `audit_log`.
- Show Mermaid ER diagram and key relationships.

3) Multi-Tenancy and Security (2:00)
- Explain `school_id` on all tables and RLS policies with `app.school_id`, `app.user_id`, `app.role`.
- Parents vs teachers vs principals/admins; encrypted columns for PII.

4) Performance Strategy (1:30)
- Indexed login path, minimal joins; dashboard aggregates; BRIN/time-series; optional partitioning; caching.

5) Extensibility (1:00)
- New features (online exams, fees) add new tables linked by `school_id` without breaking existing ones; use versioned migrations.

6) Demo Queries (1:00)
- Teacher dashboard and parent mobile queries from `sql/004_sample_queries.sql`.

7) Wrap-up (0:30)
- Summarize targets met (login <5s, secure data, scalable design).
