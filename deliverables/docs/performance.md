### Performance Plan (Login < 5s, Fast Dashboards)

- **Login path**:
  - Index on `(school_id, email)` ensures O(log n) lookup.
  - Verify password hash and issue JWT with minimal queries (users + staff/parent profile). Avoid N+1.
  - Create `session` row asynchronously where possible; return JWT immediately, enqueue audit write.
  - Warm cache of teacher dashboard aggregates on login using background jobs.

- **Teacher dashboard (<1-2s target)**:
  - Precompute class rosters (materialized view or nightly job), keyed by `(school_id, teacher_user_id, academic_year)`.
  - Indexes: `idx_class_school_teacher`, `idx_enrollment_class`, `idx_attendance_class_date` support immediate loads for today's attendance.
  - Use summary queries that fetch: today’s attendance status counts, recent grades posted, upcoming assessments.

- **Parent mobile (<1s target on decent network)**:
  - Use compact endpoints returning latest attendance (last 7-14 days) and grade deltas. Indexed by `(school_id, student_id, class_date)` and `(school_id, student_id, graded_at)`.
  - Pagination and If-Modified-Since/ETag to minimize transfer.

- **High-write tables**:
  - BRIN indexes on time columns (`attendance.created_at`, `grade.graded_at`, `audit_log.created_at`) for low-cost time-window queries.
  - Optional partitioning by `school_id` to enable pruning and move heavy schools to separate storage classes.

- **Connection and query hygiene**:
  - Use connection pooling, prepared statements, and avoid chatty transactions.
  - Keep RLS cheap by indexing `(school_id, ...)` on all hot tables.

- **Growth to 500+ schools**:
  - Horizontal: read replicas for read-heavy endpoints; partition large tenants.
  - Vertical: increase `work_mem`, `shared_buffers` appropriately; monitor slow queries.
