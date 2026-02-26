# Domain Architecture Reference: Data Platform

## Overview

A data platform is the infrastructure and architecture for collecting, storing, processing, and serving data across an organization. Architecturally, it's a system of systems — covering ingestion, storage, transformation, serving, and governance. The key tension is between centralized control and distributed ownership.

---

## Key Architectural Decisions

### Decision 1: Data Architecture Paradigm

**Context:** The fundamental model for how data is organized, owned, and consumed.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Data warehouse (centralized, schema-on-write) | Analytics-focused, structured data, SQL-centric teams | Rigid schema, ETL bottlenecks, central team is bottleneck |
| Data lake (centralized storage, schema-on-read) | Diverse data types, ML workloads, explore-first | Can become data swamp without governance, query perf varies |
| Data lakehouse (lake + warehouse capabilities) | Want both flexibility and performance, Spark/Trino ecosystem | Emerging pattern, tooling maturity varies |
| Data mesh (decentralized, domain-owned data products) | Large org, multiple domains, team autonomy over data | Requires organizational maturity, platform team investment |
| Event-driven (streaming-first) | Real-time requirements, event sourcing, reactive systems | Streaming infra complexity, eventual consistency |
| Hybrid (operational + analytical with clear boundary) | Most orgs — transactional DB for apps, analytical store for reporting | Data duplication, sync latency, two systems |

### Decision 2: Ingestion Strategy

**Context:** How data enters the platform from source systems.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Batch ETL (scheduled extracts) | Stable sources, daily/hourly freshness is fine | Latency, large processing windows, failure recovery is batch-sized |
| Batch ELT (load raw, transform in platform) | Want raw data preserved, transform in SQL/dbt | Storage costs for raw data, compute for transformation |
| Change Data Capture (CDC) | Near-real-time from databases, event-level granularity | CDC tooling complexity (Debezium), schema evolution |
| Streaming ingestion (Kafka, Kinesis) | Real-time event streams, high throughput | Streaming infra to operate, ordering guarantees, backpressure |
| API-based ingestion (pull from SaaS/APIs) | Third-party data sources, scheduled pulls | Rate limits, API versioning, reliability of external APIs |
| File drops (S3, SFTP) | Partner data, legacy systems, bulk transfers | Irregular delivery, schema inconsistency, manual monitoring |
| Hybrid (batch + streaming) | Different sources have different freshness needs | Two ingestion paths to maintain, deduplication at boundary |

### Decision 3: Storage Layer Architecture

**Context:** Where data lives at rest and how it's organized.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Cloud data warehouse (Snowflake, BigQuery, Redshift) | SQL-centric analytics, managed infrastructure | Cost at scale, vendor lock-in, less flexibility for non-SQL |
| Object storage + table format (S3 + Iceberg/Delta/Hudi) | Lakehouse approach, open formats, multi-engine | More components to manage, format maturity varies |
| Traditional RDBMS (Postgres, MySQL) | Small scale, operational analytics, familiar tooling | Scaling limits, not designed for analytical workloads |
| Time-series database (InfluxDB, TimescaleDB, ClickHouse) | IoT, metrics, event data with time dimension | Specialized, may not fit general analytics |
| Graph database (Neo4j, Neptune) | Relationship-heavy data, knowledge graphs | Niche, different query paradigm |
| Polyglot (different stores for different needs) | Diverse data types and access patterns | Operational complexity, data sync between stores |

### Decision 4: Transformation Architecture

**Context:** Where and how raw data becomes useful analytical data.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| dbt (SQL-based transforms in warehouse) | SQL-centric team, warehouse-based analytics | Limited to SQL expressiveness, warehouse compute costs |
| Spark / distributed compute | Large-scale processing, ML feature engineering, complex transforms | Infrastructure complexity, JVM ecosystem |
| Stream processing (Flink, Kafka Streams, Spark Streaming) | Real-time transformations, event processing | Stateful stream processing is complex, debugging is hard |
| Python scripts / Airflow tasks | Custom logic, data science workflows | Harder to test, maintain, and scale than SQL-based approaches |
| Stored procedures / in-database | Simple transforms, database-native | Vendor lock-in, hard to version control, testing challenges |
| ELT with materialized views | Simple aggregations, real-time-ish freshness | Limited transform complexity, refresh overhead |

### Decision 5: Orchestration

**Context:** How data pipelines are scheduled, monitored, and coordinated.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Airflow | Complex DAGs, Python-native, large ecosystem | Operational overhead, scheduler can be bottleneck |
| Dagster | Asset-oriented, software-defined data, strong typing | Newer, smaller ecosystem than Airflow |
| Prefect | Modern Python orchestration, simpler than Airflow | Managed service dependency for full features |
| dbt Cloud / dbt Core + scheduler | dbt-centric workflows, SQL transforms | Limited to dbt jobs, not general-purpose orchestration |
| n8n / workflow automation | Low-code, integrations-heavy, non-engineer users | Less suited for heavy data processing |
| Kubernetes CronJobs | Simple scheduled jobs, already on K8s | No DAG dependencies, limited monitoring, no retries |
| Event-driven (trigger on data arrival) | Reactive pipelines, no fixed schedule | Complex failure handling, harder to reason about timing |

### Decision 6: Data Serving Layer

**Context:** How processed data is made available to consumers (dashboards, APIs, ML models).

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Direct warehouse query (BI tool → warehouse) | Simple, BI-centric, managed concurrency | Warehouse costs scale with queries, cold start latency |
| Semantic layer (Cube, Looker modeling, dbt metrics) | Want consistent definitions, governed metrics | Additional layer to maintain, another abstraction |
| API layer (REST/GraphQL over data) | Application consumption, programmatic access | Custom development, caching strategy needed |
| Materialized views / OLAP cubes | Pre-computed aggregations, fast dashboard queries | Storage for pre-computed data, refresh latency |
| Feature store (Feast, Tecton) | ML model serving, feature reuse across models | ML-specific, additional infrastructure |
| Reverse ETL (Census, Hightouch) | Push data back to operational systems (CRM, marketing) | Sync complexity, data freshness, operational system limits |

### Decision 7: Governance and Cataloging

**Context:** How data is discovered, documented, and controlled.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Data catalog (DataHub, Amundsen, OpenMetadata) | Want discoverability, lineage, documentation | Another tool to maintain, adoption requires cultural buy-in |
| dbt docs + metadata | Already using dbt, want lightweight documentation | Limited to dbt-managed assets, no broader catalog |
| Wiki / manual documentation | Small team, informal governance | Goes stale, no automation, doesn't scale |
| Column-level lineage (automatic) | Want to trace data from source to report | Tooling complexity, not all tools support it |
| Data contracts (schema registries, contract tests) | Producer-consumer boundaries, prevent breaking changes | Organizational alignment needed, enforcement mechanism |
| No formal governance | Very early stage, exploring | Will bite you later — at least document critical datasets |

---

## Pattern Options

### Pattern 1: Medallion Architecture (Bronze/Silver/Gold)

**What it is:** Data flows through three quality tiers — raw ingested data (bronze), cleaned/conformed data (silver), business-level aggregations (gold).
**When to use:** Lakehouse architectures, want clear data quality progression, multiple consumers at different quality levels.
**When to avoid:** Simple analytics on a single source where the tiers add overhead without benefit.
**Combines well with:** dbt (transform between tiers), Iceberg/Delta (table format per tier), data mesh (each domain has its own medallion).

### Pattern 2: Data Mesh

**What it is:** Decentralized data ownership where domain teams own their data as products. A platform team provides self-serve infrastructure. Federated governance ensures interoperability.
**When to use:** Large organizations with multiple data-producing domains, central data team is a bottleneck.
**When to avoid:** Small org, single domain, when centralized ownership works fine.
**Combines well with:** Turborepo (domain packages produce data products), Kubernetes (platform infrastructure), self-serve platform patterns.

### Pattern 3: Streaming + Batch Lambda/Kappa Architecture

**What it is:** Lambda processes data through both batch and stream paths, merging results. Kappa simplifies to streaming-only with reprocessing capability.
**When to use:** Need both real-time and historical analytics, event-heavy systems.
**When to avoid:** When batch-only freshness is acceptable (Lambda/Kappa add significant complexity).
**Combines well with:** Kafka, Flink, event-driven architecture, Kubernetes for processing infrastructure.

### Pattern 4: Modern Data Stack (Cloud-Native)

**What it is:** Composable cloud services — managed warehouse (Snowflake/BigQuery) + ingestion (Fivetran/Airbyte) + transformation (dbt) + BI (Looker/Metabase) + orchestration (Airflow/Dagster).
**When to use:** Small-medium data teams wanting productivity over control, cloud-first.
**When to avoid:** When cost control is critical (managed services add up), air-gapped environments.
**Combines well with:** Cloud-native infrastructure, minimal ops team.

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| Data swamp | Lake full of undocumented, unowned, untrusted data | Nobody trusts or uses the data, storage costs grow | Governance, cataloging, ownership, quality checks |
| Central team bottleneck | Every data request goes through one team | Slow delivery, team burnout, consumers build shadow pipelines | Self-serve platform, domain ownership, or at least embedded analysts |
| Copy-paste pipelines | Each pipeline is hand-written with duplicated patterns | Maintenance nightmare, inconsistent quality | Templates, frameworks, shared pipeline libraries |
| Premature streaming | Building real-time pipelines when daily batch would suffice | 10x complexity for freshness nobody actually needs | Ask "what decisions change with fresher data?" first |
| Dashboard graveyard | Hundreds of dashboards, most unused, metrics undefined | Conflicting numbers, no trust, wasted effort | Governed metrics layer, usage tracking, regular cleanup |
| No testing | Pipelines with no data quality checks | Bad data reaches consumers, trust erodes | dbt tests, Great Expectations, data contracts |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| Data freshness SLOs | Data arrives within expected timeframe | Monitor pipeline completion times, alert on SLO breach |
| Schema contract tests | Upstream changes don't break downstream | Schema registry, contract tests in CI, dbt schema tests |
| Data quality checks | No nulls/duplicates/out-of-range in critical fields | dbt tests, Great Expectations, custom assertions per dataset |
| Pipeline success rate | Pipelines complete without failure | Orchestrator monitoring, alert on failure rate degradation |
| Query performance budget | Dashboard queries complete within threshold | Query profiling, Snowflake query history, BigQuery slot usage |
| Cost monitoring | Data platform spend stays within budget | Cloud cost dashboards, per-pipeline cost attribution |
| Lineage coverage | All critical datasets have documented lineage | Catalog coverage metrics, alert on undocumented new tables |

---

## Decision Checklist

Before finalizing data platform architecture:

- [ ] Data architecture paradigm chosen (warehouse, lake, lakehouse, mesh)
- [ ] Ingestion strategy per source type defined
- [ ] Storage layer selected with retention and partitioning strategy
- [ ] Transformation approach documented (dbt, Spark, streaming)
- [ ] Orchestration tool selected and DAG structure planned
- [ ] Serving layer defined for each consumer type (BI, API, ML)
- [ ] Governance approach chosen (catalog, contracts, ownership model)
- [ ] Data quality testing in place for critical datasets
- [ ] Cost monitoring and optimization strategy defined
- [ ] Access control and security model documented
- [ ] DR and backup strategy for critical data assets