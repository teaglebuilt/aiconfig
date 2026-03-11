# Claude Code Decision Frameworks

## Agent vs Skill Boundary

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Agent (persona-only) | Defining reasoning style, principles, communication approach | Cannot be invoked directly; requires a skill to trigger |
| Skill (with `agent:` frontmatter) | Task-specific procedures with routing logic that benefits from a dedicated persona | More files to maintain; skill is the entry point, agent is the persona |
| Skill (standalone, no agent) | Simple, self-contained tasks that don't need a specialized reasoning persona | Less flexibility for complex multi-step reasoning |

## Knowledge Organization Strategy

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| By domain (kubernetes/, frontend/) | Multiple agents/skills need the same domain knowledge | Routing tables in skills must be kept in sync |
| By consumer (architect-knowledge/, dev-knowledge/) | Agents need fundamentally different views of the same tech | Duplication when both need the same facts |
| Hybrid (shared domain + consumer overlays) | Large teams with specialized roles | Complexity of layered loading |

## Context Fork vs Inline Execution

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| `context: fork` | Heavy tasks loading many files (architecture analysis, code generation) | Higher latency; results must be summarized back |
| `context: inline` (default) | Quick lookups, simple transforms, memory operations | Pollutes main context with loaded files |

## Hook Integration Points

| Option | Best When | Tradeoff |
|--------|-----------|----------|
| Pre-tool hooks (validation) | Enforcing rules before file writes, commits, destructive actions | Adds latency to every tool call; can block workflow |
| Post-tool hooks (side effects) | Logging, notifications, syncing state after actions complete | Cannot prevent the action; only react to it |
| Notification hooks | Integrating with external systems on session events | Limited to session-level events |

## Observability Architecture Selection

**Use Event Streaming When:**
- Real-time monitoring required
- Multiple consumers need event data
- Live dashboards and alerts needed

**Use Batch Processing When:**
- Historical analysis and reporting
- Cost optimization critical
- Near-real-time acceptable (1-5 min delay)

**Use Hybrid Architecture When:**
- Need both real-time and batch capabilities
- Different SLAs for different data consumers

## Configuration Anti-Patterns

| Anti-Pattern | What It Looks Like | What to Do Instead |
|-------------|-------------------|-------------------|
| System prompt as agent | Full system prompt pasted into agent .md | Keep agents focused on persona; system config in CLAUDE.md |
| Duplicate routing tables | Same domain list in SKILL.md and agent .md | Single source of truth in SKILL.md |
| Empty placeholder files | Agent/knowledge files with no content | Delete or populate |
| Phantom tool references | Agent lists tools that aren't configured | Only list tools available in MCP config |
