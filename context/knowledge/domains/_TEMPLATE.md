# Domain Architecture Reference: [Domain Name]

> Use this template when creating new domain references. Every section is required to maintain consistency across domains.
>
> **File placement:** Place this file in the appropriate domain folder under `context/knowledge/domains/`. If no folder exists for this domain group, create one. If a subject belongs alongside an existing domain (e.g., a new K8s-related tool), add it to that folder. Update any skill `SKILL.md` routing tables that reference domains after adding.

---

## Overview

[1-2 sentences: What is this technology/domain and what architectural role does it play?]

---

## Key Architectural Decisions

These are the decisions you MUST make when incorporating this domain. Each decision has viable options — none is universally correct.

### Decision 1: [Decision Name]

**Context:** [Why this decision matters]

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| [Option A] | [Conditions] | [What you give up] |
| [Option B] | [Conditions] | [What you give up] |
| [Option C] | [Conditions] | [What you give up] |

### Decision 2: [Decision Name]

[Same format]

---

## Pattern Options

### Pattern 1: [Name]

**What it is:** [Brief description]
**When to use:** [Conditions that make this the right choice]
**When to avoid:** [Conditions that make this a poor choice]
**Combines well with:** [Other patterns or domains]

### Pattern 2: [Name]

[Same format]

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| [Name] | [Symptoms] | [Consequences] | [Better approach] |

---

## Fitness Functions

Automated checks to validate architectural intent holds over time.

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| [Name] | [What rule it enforces] | [Tool/command/test] |

---

## Combines With

How this domain intersects with other domain references in this skill.

| Domain | Intersection | Key Consideration |
|--------|-------------|-------------------|
| [Other domain] | [How they interact] | [What to watch for] |

---

## Decision Checklist

Before finalizing architecture involving this domain, confirm:

- [ ] [Critical question 1]
- [ ] [Critical question 2]
- [ ] [Critical question 3]