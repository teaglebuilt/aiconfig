# Domain Architecture Reference: Claude Code

> Architectural decisions for configuring, extending, and automating Claude Code as part of a development infrastructure.

---

## Overview

Claude Code is Anthropic's CLI-based AI coding assistant that supports agents, skills, hooks, and MCP integrations. Architecturally, it functions as an agent orchestration platform where the configuration structure (agents, skills, knowledge files, hooks) determines how effectively AI assists development workflows.

---

## Key Architectural Decisions

### Decision 1: Agent vs Skill Boundary

**Context:** Both agents and skills can encapsulate reusable behavior. Choosing the wrong abstraction leads to duplication or overly complex configurations.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Agent (persona-only) | Defining reasoning style, principles, and communication approach | Cannot be invoked directly; requires a skill to trigger |
| Skill (with `agent:` frontmatter) | Task-specific procedures with routing logic that benefits from a dedicated persona | More files to maintain; skill is the entry point, agent is the persona |
| Skill (standalone, no agent) | Simple, self-contained tasks that don't need a specialized reasoning persona | Less flexibility for complex multi-step reasoning |

### Decision 2: Knowledge Organization Strategy

**Context:** Knowledge files inform both agents and skills. Organizing by consumer (architect vs developer) creates duplication; organizing by domain risks files becoming too broad.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| By domain (kubernetes/, frontend/, etc.) | Multiple agents/skills need the same domain knowledge | Routing tables in skills must be kept in sync |
| By consumer (architect-knowledge/, dev-knowledge/) | Agents need fundamentally different views of the same tech | Duplication when both need the same facts |
| Hybrid (shared domain + consumer-specific overlays) | Large teams with specialized roles | Complexity of layered loading |

### Decision 3: Context Fork vs Inline Execution

**Context:** Skills can run in the main conversation (`context: inline`) or in a forked subagent (`context: fork`). This affects token usage, isolation, and conversation pollution.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| `context: fork` | Heavy tasks (architecture analysis, code generation) that load many files | Higher latency; results must be summarized back |
| `context: inline` (default) | Quick lookups, simple transforms, memory operations | Pollutes main context with loaded files |

### Decision 4: Hook Integration Points

**Context:** Hooks execute shell commands in response to Claude Code events (pre/post tool calls, notifications). They can enforce policies, trigger CI, or log activity.

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Pre-tool hooks (validation) | Enforcing rules before file writes, commits, or destructive actions | Adds latency to every tool call; can block workflow |
| Post-tool hooks (side effects) | Logging, notifications, syncing state after actions complete | Cannot prevent the action; only react to it |
| Notification hooks | Integrating with external systems (Slack, dashboards) on session events | Limited to session-level events |

---

## Pattern Options

### Pattern 1: Skill-Agent Pair

**What it is:** A skill defines procedures and routing; its frontmatter points to an agent that defines persona and reasoning principles.
**When to use:** Complex tasks requiring domain expertise, multi-step procedures, and knowledge loading.
**When to avoid:** Simple one-shot tasks where a standalone skill suffices.
**Combines well with:** Domain knowledge files, templates, reference documents.

### Pattern 2: Standalone Skill

**What it is:** A single SKILL.md with no agent reference. Runs inline or forked without a specialized persona.
**When to use:** Utility tasks (memory init, session logging, RSS checking) that follow a fixed procedure.
**When to avoid:** Tasks requiring nuanced reasoning or multiple valid approaches.
**Combines well with:** Workflow guides, data integrity procedures.

### Pattern 3: MCP Tool Composition

**What it is:** Skills that orchestrate multiple MCP server tools (YouTube, Firecrawl, LanceDB) into a cohesive workflow.
**When to use:** Tasks that span multiple external services or data sources.
**When to avoid:** When a single tool call suffices; over-orchestrating adds complexity.
**Combines well with:** Fork context (keeps main conversation clean).

---

## Anti-Patterns

| Anti-Pattern | What It Looks Like | Why It Hurts | What to Do Instead |
|-------------|-------------------|-------------|-------------------|
| System prompt as agent | Pasting the full system prompt into an agent .md file | Circular — the agent re-invokes itself; massive token waste | Keep agents focused on persona; system-level config belongs in CLAUDE.md |
| Duplicate routing tables | Same domain file list in both SKILL.md and agent .md | Two sources of truth; drift when adding domains | Single source of truth in SKILL.md; agent references the skill |
| Empty placeholder files | Agent or knowledge files with no content | Confuse routing logic; suggest completeness that doesn't exist | Delete or populate; empty files are worse than missing ones |
| Phantom tool references | Agent lists tools (redis, vector-db) that aren't configured | Agent cannot function; false expectations | Only list tools available in the actual MCP config |

---

## Fitness Functions

| Check | What It Validates | How to Implement |
|-------|------------------|-----------------|
| No empty agents | Every .md in agents/ has >10 lines of content | `find .claude/agents -name "*.md" -exec sh -c 'test $(wc -l < "$1") -le 1 && echo "$1"' _ {} \;` |
| Skills have SKILL.md | No flat .md files directly in .claude/skills/ | `find .claude/skills -maxdepth 1 -name "*.md" -type f` (should return empty) |
| Routing table consistency | Domain files referenced in SKILL.md actually exist | Script that parses routing tables and checks file existence |
| No duplicate routing | Domain routing table exists in exactly one place per skill | Grep for domain paths; ensure they appear in SKILL.md only, not agent .md |

---

## Combines With

| Domain | Intersection | Key Consideration |
|--------|-------------|-------------------|
| MCP | Skills orchestrate MCP tools; hooks can trigger MCP operations | Ensure MCP servers are configured before skills reference their tools |
| Git/CI | Hooks can enforce commit conventions, trigger builds | Pre-commit hooks vs Claude Code hooks — don't duplicate enforcement |
| Memory system | Skills like /log-session and /recall interact with memory files | Use data-integrity workflow for concurrent access safety |

---

## Decision Checklist

Before finalizing Claude Code configuration involving this domain, confirm:

- [ ] Every agent has a clear persona distinct from the system prompt
- [ ] Every skill with complex routing uses `context: fork` to avoid polluting main context
- [ ] Domain routing tables exist in exactly one place (the SKILL.md)
- [ ] No agent references tools that aren't available in the MCP configuration
- [ ] Empty placeholder files have been either populated or removed
- [ ] Flat skill files have been migrated to `{name}/SKILL.md` directory format
