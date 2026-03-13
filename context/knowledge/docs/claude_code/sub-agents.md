# Claude Code Sub‑Agents

Create and use specialized AI **sub‑agents** in Claude Code to handle
task‑specific workflows and improve context management.

Sub‑agents allow Claude Code to delegate work to specialized assistants
with their own instructions, tools, and context. This enables more
focused reasoning and prevents the main conversation from becoming
overloaded.

------------------------------------------------------------------------

# What Are Sub‑Agents?

Sub‑agents are **preconfigured AI personas** that Claude Code can
delegate tasks to.

Each sub‑agent:

-   Has a **specific purpose or specialization**
-   Runs in its **own context window**
-   Has its own **system prompt**
-   Can be restricted to specific **tools**
-   Returns results back to the main Claude agent

This separation helps maintain cleaner context and allows Claude to
orchestrate multiple specialized workers.

------------------------------------------------------------------------

# Why Use Sub‑Agents

Sub‑agents help with:

## Context isolation

Each agent runs independently so the main conversation stays small.

## Specialization

Agents can be tuned for specific tasks like:

-   Code review
-   Security analysis
-   Documentation generation
-   Architecture design

## Parallel workflows

Multiple sub‑agents can analyze different pieces of a problem
simultaneously.

## Cleaner prompts

Instead of one huge prompt, the system delegates focused tasks to
smaller agents.

------------------------------------------------------------------------

# Creating Sub‑Agents

You can create sub‑agents in two ways.

## 1. Using the `/agents` Command

The easiest way is through the CLI:

    /agents

Example:

    /agents create code-reviewer "Expert code reviewer"

Claude will generate the agent configuration automatically.

------------------------------------------------------------------------

## 2. Manually Creating an Agent File

Sub‑agents are stored as **Markdown files with YAML frontmatter**.

Location options:

    .claude/agents/

or

    ~/.claude/agents/

Example:

``` markdown
---
name: code-reviewer
description: Expert code review for quality and security
tools:
  - Read
  - Grep
  - Glob
model: sonnet
---

You are a senior code reviewer.

Evaluate code for:

1. Code quality and readability
2. Security issues
3. Performance improvements
4. Best practices
```

Claude Code can automatically call this agent when relevant.

------------------------------------------------------------------------

# How Claude Uses Sub‑Agents

Claude automatically delegates tasks when it detects that a sub‑agent's
expertise is relevant.

Typical flow:

1.  User asks Claude to perform a task
2.  Claude determines if a specialized agent is appropriate
3.  Claude spawns the sub‑agent
4.  The sub‑agent performs the work
5.  The result is returned and summarized

------------------------------------------------------------------------

# Recommended Sub‑Agents

Common examples include:

## Code Reviewer

Checks code for:

-   Security issues
-   Performance problems
-   Style violations

## Security Reviewer

Analyzes:

-   Dependency vulnerabilities
-   Secrets in code
-   Authentication flows

## Documentation Writer

Generates:

-   API docs
-   Architecture docs
-   README files

## Tech Lead Agent

Reviews architecture and design decisions.

------------------------------------------------------------------------

# Best Practices

## Keep agents specialized

Each agent should solve **one type of problem well**.

## Limit tools

Only allow the tools the agent actually needs.

## Use project‑level agents

Place them in:

    .claude/agents/

So the whole team can share them.

## Review outputs

Treat sub‑agent output like a teammate's work --- review and refine.

------------------------------------------------------------------------

# Example Use Cases

## Codebase analysis

Spawn agents to analyze:

-   backend
-   frontend
-   infrastructure

Then combine results.

## Incident analysis

Each agent investigates logs from different services.

## Large documentation tasks

Agents generate different sections simultaneously.

------------------------------------------------------------------------

# Related Concepts

  Feature      Purpose
  ------------ ---------------------------------
  Skills       Reusable knowledge/instructions
  Hooks        Intercept tool calls
  Sub‑agents   Independent specialized agents

------------------------------------------------------------------------

# Summary

Sub‑agents allow Claude Code to act like a **team of specialists instead
of a single assistant**.

They help:

-   isolate context
-   improve accuracy
-   scale complex workflows
-   structure multi‑agent reasoning
