
# Prisma ORM

Expert guidance for Prisma schema design, migrations, and PostgreSQL integration.

## When to Use This Skill

- Designing or reviewing Prisma schemas
- Creating, modifying, or troubleshooting migrations
- Multi-schema PostgreSQL configurations
- PostgreSQL extensions (pgvector, PostGIS, uuid-ossp)
- Database introspection and legacy database mapping
- Table inheritance and polymorphic patterns
- Performance optimization and indexing strategies

## Schema Design

### Model Relationships

**One-to-Many:**
```prisma
model User {
  id    Int     @id @default(autoincrement())
  posts Post[]
}

model Post {
  id       Int  @id @default(autoincrement())
  author   User @relation(fields: [authorId], references: [id])
  authorId Int
}
```

**Many-to-Many (explicit join table for additional fields):**
```prisma
model Post {
  id         Int            @id @default(autoincrement())
  categories CategoryPost[]
}

model Category {
  id    Int            @id @default(autoincrement())
  posts CategoryPost[]
}

model CategoryPost {
  post       Post     @relation(fields: [postId], references: [id])
  postId     Int
  category   Category @relation(fields: [categoryId], references: [id])
  categoryId Int
  assignedAt DateTime @default(now())

  @@id([postId, categoryId])
}
```

**Self-Relations:**
```prisma
model Employee {
  id        Int        @id @default(autoincrement())
  manager   Employee?  @relation("Management", fields: [managerId], references: [id])
  managerId Int?
  reports   Employee[] @relation("Management")
}
```

### Essential Attributes

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `@id` | Primary key | `id Int @id` |
| `@unique` | Unique constraint | `email String @unique` |
| `@default` | Default value | `createdAt DateTime @default(now())` |
| `@relation` | Define relationship | `@relation(fields: [userId], references: [id])` |
| `@map` | Column name mapping | `firstName String @map("first_name")` |
| `@@map` | Table name mapping | `@@map("user_accounts")` |
| `@updatedAt` | Auto-update timestamp | `updatedAt DateTime @updatedAt` |
| `@@index` | Database index | `@@index([email, status])` |
| `@@unique` | Composite unique | `@@unique([orgId, email])` |

### Index Strategies

```prisma
model Order {
  id        Int      @id @default(autoincrement())
  userId    Int
  status    String
  createdAt DateTime @default(now())
  
  // Single column index
  @@index([userId])
  
  // Composite index (order matters for query patterns)
  @@index([status, createdAt])
  
  // Partial index with where clause (PostgreSQL)
  @@index([status], map: "active_orders_idx", type: BTree)
}
```

## Multi-Schema Configuration

For PostgreSQL databases with multiple schemas:

```prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["multiSchema"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  schemas  = ["auth", "app", "analytics"]
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  
  @@schema("auth")
}

model Order {
  id     Int @id @default(autoincrement())
  userId Int
  
  @@schema("app")
}
```

Cross-schema relations work normally—Prisma handles the qualified table names.

## PostgreSQL Extensions

### pgvector for Embeddings

```prisma
model Document {
  id        Int                   @id @default(autoincrement())
  content   String
  embedding Unsupported("vector(1536)")?
  
  @@index([embedding], type: Hnsw(m: 16, efConstruction: 64))
}
```

Create extension and enable in migration:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Query with raw SQL:
```typescript
const similar = await prisma.$queryRaw`
  SELECT id, content, embedding <=> ${queryVector}::vector AS distance
  FROM "Document"
  ORDER BY distance
  LIMIT 10
`;
```

### Custom Database Functions

Define in a migration, then call via `$queryRaw`:

```sql
-- In migration file
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INT)
RETURNS DECIMAL AS $$
  SELECT SUM(quantity * price) FROM order_items WHERE order_id = $1;
$$ LANGUAGE SQL;
```

```typescript
const total = await prisma.$queryRaw`
  SELECT calculate_order_total(${orderId})
`;
```

## Migration Workflow

### Common Commands

```bash
# Development: create and apply migration
prisma migrate dev --name add_user_status

# Production: apply pending migrations
prisma migrate deploy

# Reset database (caution: data loss)
prisma migrate reset

# Check migration status
prisma migrate status

# Resolve failed migration (mark as applied/rolled-back)
prisma migrate resolve --applied "20240115000000_migration_name"

# Introspect existing database
prisma db pull

# Push schema without migration history (prototyping only)
prisma db push
```

### Handling Migration Issues

**"Relation does not exist" error:**
Usually caused by migration order. Check that referenced tables are created before foreign keys. Solution: modify migration SQL to reorder CREATE TABLE statements.

**Data loss warnings:**
Prisma warns when migrations might delete data. Review the migration SQL carefully. For column type changes, consider a multi-step approach:
1. Add new column
2. Migrate data with UPDATE
3. Remove old column

**Drift detection:**
When `prisma migrate dev` reports drift, your database differs from migration history. Either:
- Run `prisma migrate reset` (dev only, loses data)
- Manually align the database and run `prisma migrate resolve`

### Baseline Migrations

For existing databases, create a baseline:

```bash
# 1. Introspect current state
prisma db pull

# 2. Create migration from schema
mkdir -p prisma/migrations/0_init
prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma --script > prisma/migrations/0_init/migration.sql

# 3. Mark as applied (don't run it—database already has these tables)
prisma migrate resolve --applied 0_init
```

## Database Mapping for Legacy Systems

When working with existing databases that don't follow Prisma conventions:

```prisma
model User {
  id        Int      @id @default(autoincrement()) @map("user_id")
  firstName String   @map("first_name")
  lastName  String   @map("last_name")
  createdAt DateTime @map("created_at") @default(now())
  
  @@map("tbl_users")
}
```

This gives you clean TypeScript names while matching existing column/table names.

## Table Inheritance Patterns

Prisma doesn't directly support PostgreSQL table inheritance, but you can model similar patterns:

**Single Table Inheritance:**
```prisma
model Vehicle {
  id          Int     @id @default(autoincrement())
  type        String  // "car", "truck", "motorcycle"
  brand       String
  // Car-specific
  numDoors    Int?
  // Truck-specific
  payloadKg   Int?
  // Motorcycle-specific
  engineCC    Int?
}
```

**Polymorphic Relations:**
```prisma
model Comment {
  id             Int    @id @default(autoincrement())
  content        String
  commentableId  Int
  commentableType String // "Post", "Video", "Photo"
  
  @@index([commentableType, commentableId])
}
```

Query with type filtering in application code.

## Performance Patterns

### Connection Pooling

For serverless/edge deployments, use Prisma Accelerate or PgBouncer:

```prisma
datasource db {
  provider  = "postgresql"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL") // For migrations
}
```

### Query Optimization

**Select only needed fields:**
```typescript
const users = await prisma.user.findMany({
  select: { id: true, email: true }
});
```

**Batch operations:**
```typescript
await prisma.user.createMany({
  data: users,
  skipDuplicates: true
});
```

**Transactions:**
```typescript
// Interactive transaction
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  await tx.account.create({ data: { userId: user.id, ...accountData } });
});

// Batch transaction
await prisma.$transaction([
  prisma.user.create({ data: user1 }),
  prisma.user.create({ data: user2 })
]);
```

## Troubleshooting Checklist

1. **Schema syntax errors:** Run `prisma validate`
2. **Type mismatches:** Check `@db.` native type annotations
3. **Relation errors:** Ensure bidirectional relations are defined
4. **Migration conflicts:** Review `prisma/migrations` folder for conflicts
5. **Connection issues:** Verify `DATABASE_URL` format and network access
6. **Shadow database errors:** Ensure user has CREATE DATABASE permission

## Quick Reference

```bash
prisma generate      # Regenerate client after schema changes
prisma studio        # Visual database browser
prisma format        # Auto-format schema file
prisma validate      # Check schema syntax
prisma db seed       # Run seed script
```