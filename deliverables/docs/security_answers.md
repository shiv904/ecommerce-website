### Security Questions Answered

1) How do you ensure School A cannot see School B's student data?
- Row Level Security enforces `school_id = current_setting('app.school_id')` on every table. All queries are automatically filtered. Indexes on `(school_id, ...)` make it fast. Separate DB roles and per-request settings prevent cross-tenant leakage.

2) Where do you store sensitive information like student grades and parent contact details?
- Grades are in `grade` (non-PII). Parent contacts and student personal info are stored in encrypted columns (`parent_profile.phone_encrypted`, `address_encrypted`, `student.personal_info_encrypted`) using envelope encryption with KMS-managed keys.

3) How do you make login secure but still fast?
- Single indexed lookup by `(school_id, email)`, Argon2id verification, minimal profile join, immediate JWT issuance, async session/audit writes, and caching common dashboard aggregates. MFA available for staff.

4) What records do you keep of who accessed what data?
- `audit_log` rows for sensitive reads and all writes, including actor, action, resource, and timestamp. BRIN index enables efficient time-window searches and compliance exports.

5) How do you handle different permission levels (principal vs teacher vs admin)?
- `staff_profile.role` encodes role. RLS policies check `app.role` to gate read/write: teachers limited to their classes, parents to linked students, principals/admins have school-wide read/write within tenant.
