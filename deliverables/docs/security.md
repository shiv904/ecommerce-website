### Security and Privacy Design

- **Multi-tenancy isolation**: All tables carry `school_id`. PostgreSQL Row Level Security enforces `school_id = current_setting('app.school_id')` across reads/writes. Additional role-aware policies restrict parents to linked students and teachers to their classes.

- **Least privilege access**: Separate DB roles for `app_parent`, `app_teacher`, `app_admin`. Application sets `app.role` and `app.user_id` per request via `SET LOCAL`, or uses a SECURITY DEFINER function that validates JWT and sets settings.

- **Sensitive data encryption**: Columns like `parent_profile.phone_encrypted`, `address_encrypted`, and `student.personal_info_encrypted` store ciphertext (AEAD). `encryption_key_id` references a KMS-stored key alias. Encryption/decryption is done in the app layer using envelope encryption to keep plaintext out of the DB. Optional pgcrypto can be used for server-side crypto where appropriate.

- **Password handling**: `user.password_hash` uses Argon2id (or bcrypt as fallback) with per-user salts and strong parameters. Never store plaintext. Force MFA for staff roles.

- **Audit logging**: `audit_log` captures actor, action, resource, and timestamp for read-sensitive and write operations. Retain with BRIN index for efficient time-window queries.

- **Network and transport**: TLS everywhere. Use private networking for DB. Rotate credentials regularly; use short-lived tokens for sessions. `session` table stores `jwt_id` for revocation and drift detection.

- **PII minimization and separation**: Store only necessary PII. Use separate encrypted columns for high-risk data. Avoid mixing academic data with PII in the same columns.

- **Backups and keys**: Encrypted backups. Keys managed in cloud KMS (e.g., AWS KMS/GCP KMS). Maintain key rotation policy and re-encrypt new data with latest version.

- **Compliance readiness**: Supports data subject rights (export/delete) via `school_id` scoping and clear joins. Access reviews enabled through `audit_log`.
