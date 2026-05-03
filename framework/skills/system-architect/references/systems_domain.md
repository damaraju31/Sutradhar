# Systems Architecture Domain Reference

Deep technical knowledge for the Systems Architect persona. Read sections as needed — this is a reference, not a sequential document.

## Table of Contents

1. [Distributed Systems Fundamentals](#1-distributed-systems-fundamentals)
2. [PostgreSQL Architecture & Patterns](#2-postgresql-architecture--patterns)
3. [Python Async Architecture](#3-python-async-architecture)
4. [Pipeline & Integration Patterns](#4-pipeline--integration-patterns)
5. [Module Design Principles](#5-module-design-principles)
6. [API Architecture](#6-api-architecture)
7. [Concurrency Patterns](#7-concurrency-patterns)
8. [Security Architecture](#8-security-architecture)
9. [Observability Patterns](#9-observability-patterns)
10. [Using Project Context](#10-using-project-context)

---

## 1. Distributed Systems Fundamentals

### Consistency Models

| Model | Guarantee | Example | the project Use |
|---|---|---|---|
| **Strong (linearizable)** | All readers see latest write immediately | Single PostgreSQL transaction | Entity creation + transaction writes |
| **Read-your-writes** | Writer sees their own writes; others may see stale | Session-scoped reads | API response after mutation |
| **Eventual** | All readers converge to latest write... eventually | Background recalculation | Net worth snapshots, nightly reconciliation |
| **Causal** | If A causes B, everyone sees A before B | Event ordering | Statement processing before analytics |

**CAP Theorem** — pragmatic interpretation: In a single-node PostgreSQL system (the project's current architecture), you have strong consistency and availability. The CAP trade-off becomes relevant only with replication or distribution. Don't over-apply CAP to a single-database system.

**PACELC** — more useful than CAP: "If Partition, choose Availability or Consistency; Else, choose Latency or Consistency." the project chooses consistency over latency (financial correctness > speed), which means synchronous net worth recalculation after entity mutations is correct, even if it adds latency.

### Idempotency Patterns

Idempotency means: executing an operation N times produces the same result as executing it once. Critical for any operation that can be retried (webhooks, background jobs, user double-clicks).

**Implementation strategies:**

| Strategy | How it works | Best for | the project Example |
|---|---|---|---|
| **Natural idempotency** | Operation is inherently idempotent (e.g., SET, not INCREMENT) | Overwrites, upserts | Setting `outstanding_amount = X` from statement |
| **Idempotency key** | Client sends unique key; server dedup on the key | API mutations | Document upload with SHA256 file hash |
| **Conditional write** | Write only if precondition holds (version, ETag, status) | Optimistic concurrency | Update document only if `status = 'processing'` |
| **Dedup table** | Record processed event IDs; skip if already seen | Webhook handlers | `gmail_message_id` preventing re-processing |

**The dedup chain** — the project's 4-level idempotency:
1. **File hash (SHA256 of raw pre-decrypt bytes)**: Blocks identical file re-upload. Cross-source: manual upload vs email attachment.
2. **Gmail message ID**: Prevents reprocessing same email message.
3. **Statement level (account + period)**: Blocks duplicate statement for same account and billing period. Depends on account resolution.
4. **Transaction fingerprint (SHA256)**: Prevents duplicate transaction records within a statement. Last line of defense.

Each level catches what the previous one misses. Breaking any level creates a double-counting risk.

### Exactly-Once Delivery

True exactly-once delivery is impossible in distributed systems (proven by the Two Generals problem). The practical solution: **at-least-once delivery + idempotent consumers**.

- n8n webhook may fire twice → document callback handler must be idempotent
- APScheduler job may run while previous run is still executing → retry logic must check document status before reprocessing
- Gmail push notification may duplicate → `gmail_message_id` dedup prevents double processing

---

## 2. PostgreSQL Architecture & Patterns

### MVCC (Multi-Version Concurrency Control)

PostgreSQL never overwrites data in-place. Every UPDATE creates a new row version. Old versions are retained for concurrent readers (snapshot isolation) and cleaned up by VACUUM.

**Implications for the project:**
- Long-running transactions hold snapshots that prevent VACUUM from cleaning old versions → table bloat
- `SELECT ... FOR UPDATE` locks the specific row version, not the row — concurrent readers still proceed
- `READ COMMITTED` (PG default, the project's level): each statement in a transaction sees the latest committed data. Two SELECTs in the same transaction can return different results if another transaction commits between them.

### Isolation Levels

| Level | Phantom Reads | Non-Repeatable Reads | Dirty Reads | Use When |
|---|---|---|---|---|
| **Read Committed** (default) | Yes | Yes | No | Most queries. Simple, performant. |
| **Repeatable Read** | No | No | No | Reports, analytics that need consistent snapshot |
| **Serializable** | No | No | No | Financial transfers, balance updates (most restrictive, may abort) |

**When to upgrade**: Account resolution (find-or-create) under concurrent access should use advisory locks or serializable isolation. The default READ COMMITTED allows the race condition where two transactions both "find nothing" and both "create."

### Locking Strategies

**Row-level locks** (`SELECT ... FOR UPDATE`):
- Locks specific rows. Other transactions block on those rows but can access others.
- Use for: "read then update" patterns where you need the read value to stay valid.
- the project example: Updating `Liability.outstanding_amount` — lock the row, read current value, compute new value, write.

**Advisory locks** (`pg_advisory_lock(key)`):
- Application-level locks. PostgreSQL manages them but attaches no semantics.
- Use for: coordinating access to logical resources that aren't single rows.
- the project example: Account resolution — `pg_advisory_xact_lock(hash(user_id || bank_name || account_number))` prevents concurrent creation of duplicate accounts.
- `pg_advisory_xact_lock` releases automatically at transaction end. Prefer over `pg_advisory_lock` which requires explicit unlock.

**Table-level locks** (DDL, `LOCK TABLE`):
- Avoid in application code. Only relevant for migrations.
- `ALTER TABLE ADD COLUMN` with a default is metadata-only in PG 11+ (fast).
- `CREATE INDEX` locks the table. Always use `CREATE INDEX CONCURRENTLY` in production.

### Index Design

| Index Type | Use Case | the project Example |
|---|---|---|
| **B-tree** (default) | Equality, range, ORDER BY | `WHERE user_id = X AND created_at > Y` |
| **GIN** | JSONB containment, array overlap, full-text | `WHERE meta_data @> '{"bank_name": "HDFC"}'` |
| **Partial** | Filter to a subset of rows | `WHERE status = 'processing'` (only index stuck documents) |
| **Composite** | Multi-column queries | `(user_id, account_number)` for account resolution |
| **Covering** | Include columns to avoid table access | `INCLUDE (amount, date)` for transaction queries |

**Index rule of thumb**: If a query filters by `user_id` (all the project queries do), `user_id` should be the leading column of the composite index. A partial index on active records is often better than indexing the full table.

### Migration Patterns

**The expand-contract pattern** (zero-downtime schema evolution):

```
Phase 1 (Expand): Add new column/table. Old code ignores it.
                   → Safe to roll back by ignoring the column.
Phase 2 (Migrate): Deploy code that writes both old and new.
                   Backfill existing data.
                   → Verify: old and new columns agree for all rows.
Phase 3 (Contract): Remove old column. Deploy code that reads only new.
                   → Dangerous: can't easily roll back.
```

**Alembic-specific patterns:**
- `op.add_column()` is safe (no lock, metadata-only with DEFAULT in PG 11+)
- `op.drop_column()` is irreversible — always have a backfill/rollback plan
- `op.create_index(... postgresql_concurrently=True)` — use `execute()` with raw SQL instead, as Alembic's concurrent index support requires `non_transactional=True` on the migration
- Always test migrations against a database with production-volume data. A migration that takes 10ms on an empty table may take 10 minutes on 1M rows.

### Connection Pooling

SQLAlchemy's `create_async_engine` manages a connection pool:
- `pool_size`: Number of persistent connections (default 5). Should match expected concurrent requests.
- `max_overflow`: Additional connections beyond pool_size (default 10). Temporary, closed when returned.
- `pool_timeout`: How long to wait for a connection before raising (default 30s).
- `pool_recycle`: Close connections older than N seconds (prevents stale connections to PostgreSQL).

**Pool exhaustion**: If all connections (pool_size + max_overflow) are in use and a new request arrives, it blocks for `pool_timeout` seconds. Common causes: long-running transactions, N+1 queries, forgotten session closes on exception paths.

---

## 3. Python Async Architecture

### The Event Loop Model

Python `asyncio` uses cooperative multitasking on a single thread. Every `await` is a yield point where other coroutines can run. A coroutine that doesn't `await` blocks the entire event loop.

**Implications:**
- CPU-bound work (JSON parsing, hash computation) blocks the loop. Use `loop.run_in_executor()` for heavy computation.
- Synchronous I/O (non-async HTTP calls, file reads) blocks the loop. Use async alternatives or executor.
- `time.sleep()` blocks the loop. Use `asyncio.sleep()`.
- A single slow synchronous call in a request handler blocks ALL concurrent requests.

### SQLAlchemy AsyncSession Lifecycle

```python
# Correct: session scoped to request via FastAPI dependency
async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        yield session
        # session is closed when the request completes

# Correct: script/background job session
async with DatabaseSession() as session:
    # session auto-commits on exit, auto-rollbacks on exception
    ...

# WRONG: session created but never closed
session = async_session_factory()
# → connection leak, pool exhaustion
```

**Relationship loading in async context:**
- `lazy="select"` (default): Triggers a query on attribute access. In async context, this raises `MissingGreenlet` because lazy loading requires synchronous I/O.
- `lazy="selectin"` or `selectinload()`: Loads related objects in a separate SELECT...IN query. Async-safe. Good for collections.
- `lazy="joined"` or `joinedload()`: Loads via JOIN in the same query. Async-safe. Good for single related objects.
- `lazy="subquery"` or `subqueryload()`: Loads via subquery. Async-safe. Good for large collections where JOIN would create cartesian product.

**The MissingGreenlet error**: Always means lazy loading was triggered in an async context. Fix by adding eager loading to the query, not by switching to sync mode.

### Common Async Pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| Blocking call in async | All requests slow down simultaneously | Use `run_in_executor()` or async library |
| Missing `await` | Coroutine object returned instead of result | Add `await` (linter catches most cases) |
| Session scope too wide | Connection held across multiple awaits | Scope session to smallest necessary operation |
| Fire-and-forget task | Silent failures, no error propagation | Use `TaskGroup` or capture task reference and check result |
| Shared mutable state | Race conditions between coroutines | Use asyncio.Lock or database-level locking |

### Structured Concurrency

Python 3.11+ `TaskGroup` (or `anyio.create_task_group`):
```python
async with asyncio.TaskGroup() as tg:
    tg.create_task(process_statement_a())
    tg.create_task(process_statement_b())
# Both tasks complete or both are cancelled on exception
```

Prefer `TaskGroup` over raw `create_task()` — it ensures all spawned tasks are awaited and exceptions propagate rather than being silently swallowed.

---

## 4. Pipeline & Integration Patterns

### Saga Pattern

A saga coordinates a multi-step process where each step has a compensating action for rollback. Instead of a distributed transaction, each step commits locally and the saga orchestrator handles failures.

**the project document processing as a saga:**
1. Upload to S3 → compensate: delete from S3
2. Send to n8n → compensate: cancel n8n workflow
3. Process callback → compensate: mark document as failed
4. Write entities → compensate: delete derived entities (the 6-step cascade)
5. Recalculate net worth → compensate: revert snapshot

Currently, steps 4-5 are in a single transaction (good — avoids partial entity state). Steps 1-3 are not transactional across each other (acceptable — each step is independently retryable via the document retry mechanism).

### Webhook Reliability

Webhooks (n8n callback, Gmail push notifications) are inherently unreliable:
- **At-least-once delivery**: The sender may retry if it doesn't receive an ACK. Your handler must be idempotent.
- **Out-of-order delivery**: Events may arrive in different order than they occurred. Don't assume ordering.
- **Timeout**: If your handler is slow, the sender may retry while you're still processing. Guard with document status checks.

**Reliable webhook handler pattern:**
1. Receive event
2. Check idempotency (has this event ID been processed?)
3. If already processed, return 200 (ACK without re-processing)
4. Process the event
5. Mark as processed (atomically with step 4 if possible)
6. Return 200

### Retry Strategies

| Strategy | When to use | Implementation |
|---|---|---|
| **Immediate retry** | Transient failures (network blip) | Retry once, then backoff |
| **Exponential backoff** | Service overload, rate limiting | `delay = base * 2^attempt + jitter` |
| **Fixed interval** | Periodic checks (document retry) | APScheduler every 2 hours |
| **Circuit breaker** | Dependency consistently failing | After N failures, stop trying for M seconds |

**Jitter is essential**: Without jitter, all retries align and create a thundering herd. Always add random jitter to backoff: `delay = base * 2^attempt * (0.5 + random() * 0.5)`.

### Dead Letter Patterns

When a message/event permanently fails after all retries:
- Don't drop it silently
- Don't retry forever (resource waste)
- Move to a "dead letter" state with the failure reason
- Alert operators for manual investigation

the project equivalent: Documents stuck in `processing` status for >24h. The document retry script handles this every 2h, but permanently failing documents need a `failed` status with error details.

---

## 5. Module Design Principles

### Deep Modules (Ousterhout)

A **deep module** has a simple interface and a complex implementation. The interface hides the complexity, making the system easier to reason about.

```
Deep module:                    Shallow module:
┌──────────────────────┐       ┌──────────────────────┐
│  Simple interface    │       │  Complex interface    │
│  (2-3 methods)       │       │  (many params/methods)│
├──────────────────────┤       ├──────────────────────┤
│                      │       │                      │
│  Complex             │       │  Simple              │
│  implementation      │       │  implementation      │
│  (lots of logic,     │       │  (thin wrapper,      │
│   error handling,    │       │   just delegates)     │
│   edge cases)        │       │                      │
│                      │       │                      │
└──────────────────────┘       └──────────────────────┘
```

**the project deep module examples:**
- `AccountResolutionService.find_or_create(user_id, bank_name, account_number)` — simple interface hiding entity lookup, creation, type inference, dedup
- `NetWorthService.calculate_and_snapshot(user_id, date)` — simple interface hiding asset aggregation, liability aggregation, snapshot upsert, delta computation
- `DeduplicationService.check_duplicate(user_id, account_id, period)` — simple interface hiding multi-strategy dedup

**Shallow module warning signs:**
- A service class where every method has 6+ parameters
- A utility function that just reformats arguments and calls another function
- A "manager" that delegates every call to another "service" without adding logic

### Coupling Taxonomy

From loosest (best) to tightest (worst):

| Type | Definition | Example | Remedy |
|---|---|---|---|
| **Data** | Modules share only primitive data | Pass `amount: Decimal` | Ideal. Preserve. |
| **Stamp** | Pass entire data structure when only fields needed | Pass full `Statement` when only `period_start` needed | Extract needed fields at boundary |
| **Control** | One module passes flags that control another's behavior | `process(doc, skip_dedup=True)` | Split into separate methods |
| **Common** | Modules share global state | Multiple services reading same config singleton | Inject configuration |
| **Content** | One module reaches into another's internals | Service A imports Service B's private helper | Expose via public interface |

### Cohesion Types

From strongest (best) to weakest (worst):

| Type | Definition | the project Example |
|---|---|---|
| **Functional** | All elements contribute to single well-defined task | `fingerprint.py` — computes transaction fingerprints |
| **Sequential** | Output of one element feeds input of next | `dispatcher.py` — routes, then processes |
| **Communicational** | Elements operate on same data | `transaction_processor.py` — creates income, expense, transactions from same extraction |
| **Temporal** | Elements execute at the same time | `startup.py` — initializes DB, scheduler, middleware at boot |
| **Logical** | Elements do similar things but are unrelated | A "utils.py" with date formatting AND file hashing |
| **Coincidental** | Elements have no meaningful relationship | A "helpers.py" grab-bag — always a smell |

### Dependency Inversion

High-level modules should not depend on low-level modules. Both should depend on abstractions.

In practice for the project (Python, pragmatic):
- Processors should depend on an abstract `EntityWriter` protocol, not directly on SQLAlchemy models
- The dispatcher should depend on a `ProcessorRegistry` interface, not on concrete processor imports
- External services (S3, n8n) should be accessed through injected clients, not through global module-level functions

This isn't about adding Java-style interfaces everywhere. It's about making test boundaries clean and making it possible to swap implementations without rewriting callers.

---

## 6. API Architecture

### REST Design Principles (the project Context)

| Principle | What it means | the project Practice |
|---|---|---|
| **Resource-oriented** | URLs are nouns, HTTP verbs are actions | `/api/v1/assets`, not `/api/v1/getAssets` |
| **Per-entity endpoints** | One resource, one endpoint | Separate endpoints per entity type (preferred over generic) |
| **Consistent error format** | Same error shape everywhere | RFC 7807 Problem Details or consistent custom format |
| **Bulk operations** | Batch when clients need it | `POST /api/v1/expenses/bulk-verify` with `{ ids: [...] }` |
| **Route ordering** | Specific before generic | `/bulk-verify` BEFORE `/{id}` (FastAPI path conflict) |

### Pagination Patterns

| Pattern | Pros | Cons | Use When |
|---|---|---|---|
| **Offset/Limit** | Simple, familiar | Skips items on insert, slow at high offsets | Small datasets, admin views |
| **Cursor (keyset)** | Stable, performant at any page | Can't jump to page N | Large datasets, infinite scroll |
| **Time-based** | Natural for chronological data | Requires monotonic timestamps | Transaction history, activity feed |

For the project: cursor-based pagination on `created_at` + `id` for transaction lists. Offset-based for small admin queries.

### Error Contract

Consistent error responses across all endpoints:

```json
{
  "error": {
    "code": "DUPLICATE_STATEMENT",
    "message": "Statement for HDFC savings account, period March 2026, already exists",
    "details": {
      "account_id": "uuid",
      "period": "2026-03"
    }
  }
}
```

Error codes should be machine-readable constants. Messages should be human-readable. Details provide context for debugging. Never expose stack traces or internal state in production error responses.

### Idempotency for Mutations

POST operations that create resources should support idempotency:
- **File upload**: SHA256 hash of file content as natural idempotency key → 409 Conflict on duplicate
- **Document processing callback**: document_id + processing status as idempotency check → skip if already processed
- **Bulk operations**: Each item in the batch should be individually idempotent → partial success is acceptable

---

## 7. Concurrency Patterns

### Optimistic Concurrency Control

Assume no conflict. Detect on write. Retry on conflict.

```sql
-- Read with version
SELECT id, outstanding_amount, version FROM liabilities WHERE id = $1;

-- Write with version check
UPDATE liabilities
SET outstanding_amount = $2, version = version + 1
WHERE id = $1 AND version = $3;

-- If 0 rows affected → concurrent modification → retry
```

**Use when**: Conflicts are rare (most the project operations). Low overhead, no lock contention.

### Pessimistic Concurrency Control

Assume conflict. Lock before read. Release after write.

```sql
-- Lock the row
SELECT * FROM liabilities WHERE id = $1 FOR UPDATE;

-- Now safe to modify
UPDATE liabilities SET outstanding_amount = $2 WHERE id = $1;

-- Lock released at COMMIT
```

**Use when**: Conflicts are frequent or the cost of retry is high. Account resolution is a candidate — creating a duplicate entity is worse than a brief lock wait.

### Advisory Locks for Logical Resources

When the resource to lock isn't a single row:

```sql
-- Lock based on a logical key (e.g., user_id + bank_name + account_number)
SELECT pg_advisory_xact_lock(hashtext($1 || $2 || $3));

-- Now safe to find-or-create
-- Lock auto-releases at transaction end
```

**the project applications:**
- Account resolution: prevent duplicate entity creation for same bank account
- Net worth recalculation: prevent concurrent snapshot writes for same user + date
- Statement processing: prevent concurrent processing of statements for same account

### Deadlock Prevention

Deadlocks occur when two transactions each hold a lock the other needs. Prevention strategies:

1. **Lock ordering**: Always acquire locks in the same order (e.g., by entity ID ascending)
2. **Lock timeout**: `SET lock_timeout = '5s'` — fail fast rather than wait forever
3. **Minimize lock duration**: Do computation outside the transaction, only hold locks during the write
4. **Advisory lock granularity**: Use the narrowest key possible (user_id + account, not just user_id)

---

## 8. Security Architecture

### Multi-Tenancy Isolation

the project uses shared-database multi-tenancy with `user_id` filtering as the isolation mechanism.

**Critical rule**: Every database query MUST filter by `user_id`. This is a security boundary, not a convenience filter. Missing `user_id` = data breach.

**Defense layers:**
1. **API layer**: `get_current_user_cognito()` dependency extracts user_id from JWT. Always pass to service methods.
2. **Service layer**: Every method signature includes `user_id: UUID`. Every query filters by it.
3. **Database layer** (future): PostgreSQL Row-Level Security could enforce `user_id` filtering at the database level, making it impossible to query without it.

### Authentication Architecture (Cognito + JIT Provisioning)

```
Client → JWT in Authorization header → FastAPI dependency validates with Cognito
       → Extracts user_id from token
       → JIT provisioning: if user_id not in DB, create User record
       → Passes user_id to route handler
```

**JIT provisioning race condition**: Two concurrent requests for a first-time user both check "user exists?" → both find "no" → both try to create → one fails with unique constraint. The Cognito dependency should handle this with an upsert or catch-and-retry pattern.

### Input Validation Boundaries

Validate at system boundaries (API endpoints), not deep in business logic:
- **Pydantic models** at API boundary: type validation, format validation, range checks
- **Database constraints** as last line of defense: NOT NULL, UNIQUE, CHECK, FK constraints
- **Business logic** should assume valid input if the boundary validates correctly

Don't validate the same thing three times. If Pydantic enforces `amount > 0`, the service layer shouldn't re-check it.

### OWASP API Security Top 10 (Relevant Subset)

| Risk | the project Relevance | Mitigation |
|---|---|---|
| **Broken Object-Level Auth** | Accessing another user's assets/liabilities | `user_id` filter on every query |
| **Broken Authentication** | Weak JWT validation | Cognito handles token validation; verify audience and issuer |
| **Excessive Data Exposure** | Returning full model objects including internal fields | Pydantic response models exclude internal fields |
| **Mass Assignment** | Setting `user_id` or `verification_status` via API body | Explicit field assignment, not `**request.dict()` |
| **Injection** | SQL injection via raw queries | SQLAlchemy ORM parameterization (never string concatenation) |

---

## 9. Observability Patterns

### Structured Logging with structlog

```python
import structlog
logger = structlog.get_logger()

# Good: structured, queryable, context-rich
logger.info("document_processed",
    document_id=str(doc.id),
    user_id=str(user_id),
    document_type=doc.document_type,
    transaction_count=len(transactions),
    duration_ms=elapsed_ms)

# Bad: unstructured, unparseable
logger.info(f"Processed document {doc.id} with {len(transactions)} transactions")
```

**Key structured logging principles:**
- Every log event is a key-value record (JSON in production)
- Use consistent field names across the codebase (`document_id`, not sometimes `doc_id`)
- Include enough context to reconstruct what happened without reading source code
- Log levels: DEBUG (development), INFO (significant events), WARNING (recoverable issues), ERROR (failures requiring attention)

### Health Check Tiers

| Endpoint | What it checks | Response time | Failure meaning |
|---|---|---|---|
| `/health/live` | Process is alive | <1ms | Container needs restart |
| `/health/ready` | Database connected | <100ms | Don't route traffic here |
| `/health` | DB + n8n + scheduler | <1s | System degraded, investigate |

**Design principle**: Liveness checks should never depend on external services (otherwise a dependency failure causes unnecessary container restarts). Readiness checks should verify the dependencies needed to serve requests.

### Correlation IDs

Trace a single user action through all pipeline stages:

```
Upload request → correlation_id generated
  → S3 upload (log: correlation_id, s3_key)
  → n8n trigger (log: correlation_id, n8n_execution_id)
  → Callback received (log: correlation_id, document_id)
  → Processing (log: correlation_id, entity_ids created)
  → Net worth update (log: correlation_id, snapshot_date)
```

With correlation IDs, an oncall engineer can query: "Show me everything that happened for correlation_id=X" and see the full lifecycle.

### RED Method for Services

For every service endpoint, track:
- **Rate**: Requests per second
- **Errors**: Error rate (4xx client errors separate from 5xx server errors)
- **Duration**: Latency distribution (p50, p95, p99)

Alert on: sudden error rate increase, latency p99 exceeding SLO, rate drop (may indicate upstream failure).

---

## 10. Using Project Context

This skill provides portable architectural thinking methodology. Project-specific knowledge (invariants, pipeline stages, known gaps, decisions) lives in the project's context hierarchy:

- **`.claude/rules/`** — Domain-level architecture context, auto-loaded when working in matching directories
- **`.claude/context/components/`** — Component-level internals, known gaps, anti-patterns
- **`.claude/context/decisions/ADR-*.md`** — Architectural decisions with rationale

When applying this skill to a specific project, read the relevant context files first. They contain the project's invariant registry, pipeline boundaries, consistency models, and known architectural gaps — the kind of information that makes the difference between a generic review and a useful one.
