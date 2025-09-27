# StudentTracker Deliverables

### Contents
- `assets/er_diagram.mmd`: Mermaid ER diagram
- `sql/001_schema.sql`: Core schema (tables, PKs, FKs)
- `sql/002_indexes_partitioning.sql`: Indexes and partitioning strategy
- `sql/003_rls_tenancy.sql`: RLS policies and tenancy helpers
- `sql/004_sample_queries.sql`: Example queries for teacher/parent flows
- `docs/security.md`: Security and privacy design
- `docs/performance.md`: Performance plan for fast login/dashboards

### Quick Start
1. Create a PostgreSQL database (v14+ recommended).
2. Apply SQL files in order:
   - `001_schema.sql`
   - `002_indexes_partitioning.sql`
   - `003_rls_tenancy.sql`
   - `004_sample_queries.sql`
3. Set tenancy context per request (app layer):
   - `SET LOCAL app.school_id = '<school-uuid>';`
   - `SET LOCAL app.user_id = '<user-uuid>';`
   - `SET LOCAL app.role = 'teacher'|'principal'|'admin'|'parent';`

### ER Diagram
Render `assets/er_diagram.mmd` with Mermaid or VS Code Mermaid viewer.

### Video
Record a 5–10 minute walkthrough covering: schema overview, growth plan to 500+ schools, <5s login strategy, security/RLS, and extensibility. See `docs/video_outline.md`.
