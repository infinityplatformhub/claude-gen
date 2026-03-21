---
name: migration-database
description: DB migration — multi-dialect, safe rollback, zero-downtime patterns. Covers GORM, Alembic, Prisma, and raw SQL migrations.
metadata:
  version: "1.0.0"
  domain: database
  triggers: migration, schema change, alter table, add column, database migration, rollback, migrate
  role: specialist
  scope: implementation
  output-format: code
  related-skills: golang-pro, debugging
---

# Database Migration

Safe database migration patterns across multiple ORMs and dialects.

## Core Principles

1. **Every migration has a rollback** — up AND down, always
2. **Additive first** — add new, migrate data, then remove old
3. **Never break running code** — deploy code that handles both old and new schema
4. **Test migrations** — run up AND down in dev before merging
5. **One concern per migration** — don't mix schema + data changes

## Migration File Naming

```
# Timestamp-based (recommended)
20240315_001_create_users_table.sql
20240315_002_add_email_index.sql

# Sequential (simpler but conflicts in teams)
001_create_users_table.sql
002_add_email_index.sql
```

## Safe Migration Patterns

### Adding a Column (Safe)
```sql
-- UP
ALTER TABLE users ADD COLUMN phone VARCHAR(20) DEFAULT NULL;

-- DOWN
ALTER TABLE users DROP COLUMN phone;
```

### Renaming a Column (3-step deployment)
```
Step 1: Add new column, backfill data
Step 2: Deploy code that writes to BOTH columns, reads from new
Step 3: Drop old column after all code uses new name
```

```sql
-- Migration 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
UPDATE users SET full_name = name WHERE full_name IS NULL;

-- Migration 2 (after code deployed): Drop old column
ALTER TABLE users DROP COLUMN name;
```

### Adding an Index (Large Tables)
```sql
-- Use CONCURRENTLY for PostgreSQL (no table lock)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- For MySQL, consider pt-online-schema-change for large tables
```

### Dropping a Table (Safe)
```sql
-- Step 1: Rename (keep as backup)
ALTER TABLE old_feature RENAME TO _old_feature_backup;

-- Step 2: Drop after confirmed no issues (separate migration, days later)
DROP TABLE IF EXISTS _old_feature_backup;
```

## GORM Migrations (Go)

```go
// Prefer manual migrations over AutoMigrate for production
// AutoMigrate is OK for development only

// Manual migration with goose or golang-migrate
// migrations/20240315001_create_users.sql

// +goose Up
CREATE TABLE users (
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,
    email      VARCHAR(255) NOT NULL UNIQUE,
    name       VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL
);

// +goose Down
DROP TABLE IF EXISTS users;
```

## Alembic Migrations (Python)

```python
"""create users table

Revision ID: abc123
Create Date: 2024-03-15
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.BigInteger(), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, unique=True),
        sa.Column('name', sa.String(255), nullable=False),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now()),
    )

def downgrade():
    op.drop_table('users')
```

## Prisma Migrations (Node.js)

```prisma
// schema.prisma — declarative, Prisma handles migration generation
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  createdAt DateTime @default(now()) @map("created_at")

  @@map("users")
}
```

```bash
# Generate migration
npx prisma migrate dev --name create_users

# Apply in production
npx prisma migrate deploy
```

## Dialect Differences

| Operation | MySQL | PostgreSQL |
|-----------|-------|------------|
| Add column with default | Rewrites table (< 8.0.12) | Instant (metadata only) |
| Add index | Locks table | `CONCURRENTLY` option |
| Rename column | `ALTER TABLE ... CHANGE` | `ALTER TABLE ... RENAME COLUMN` |
| JSON type | `JSON` (validated) | `JSONB` (indexed) |
| Boolean | `TINYINT(1)` | `BOOLEAN` |
| Auto increment | `AUTO_INCREMENT` | `SERIAL` / `GENERATED ALWAYS` |

## Zero-Downtime Migration Strategy

```
1. Deploy code that handles BOTH old and new schema
2. Run migration (additive changes only)
3. Deploy code that uses new schema exclusively
4. Run cleanup migration (remove old columns/tables)
```

## Dangerous Operations Checklist

Before running any of these, ask the user:

- [ ] `DROP TABLE` — is there a backup? Is the table truly unused?
- [ ] `DROP COLUMN` — is any code still referencing it?
- [ ] `ALTER COLUMN TYPE` — will existing data convert cleanly?
- [ ] `ADD NOT NULL` without default — will existing rows fail?
- [ ] Large table `ALTER` — is there a maintenance window?
- [ ] Data migration — is it idempotent? Can it be re-run safely?

## Constraints

### MUST DO
- Write both up and down migrations
- Test migrations in dev before production
- Use transactions where supported (PostgreSQL)
- Back up data before destructive migrations
- Keep migrations immutable — never edit a deployed migration

### MUST NOT DO
- Use `AutoMigrate` in production (Go/GORM)
- Drop columns without verifying no code references them
- Mix schema and data changes in one migration
- Skip the rollback script
- Run migrations without a backup strategy
