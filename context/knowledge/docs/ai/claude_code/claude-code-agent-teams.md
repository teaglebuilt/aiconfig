# Claude Code Agent Teams

Agent Teams allow you to coordinate multiple Claude Code sessions
working together on the same task. One session acts as the team lead,
organizing work and assigning tasks to other agents.

Instead of a single AI agent solving everything sequentially, Agent
Teams split work across several specialized agents that operate in
parallel.

------------------------------------------------------------------------

# What Are Agent Teams?

Agent Teams are groups of Claude Code instances collaborating on a
shared goal.

Each team typically includes:

  Role               Description
  ------------------ ---------------------------------------------
  Team Lead          Coordinates tasks and manages progress
  Team Members       Independent Claude sessions performing work
  Shared Task List   Tracks tasks and dependencies
  Messaging          Agents communicate directly with each other

Each teammate runs in a separate context window, allowing them to focus
on their assigned work without polluting other contexts.

------------------------------------------------------------------------

# How Agent Teams Work

Typical workflow:

1.  User describes a complex task
2.  Claude creates a team of agents
3.  The lead agent splits the work into tasks
4.  Agents run in parallel
5.  Results are merged and returned

Example conceptual structure:

    User Task
       │
       ▼
    Team Lead Agent
       │
       ├── Backend Agent
       ├── Frontend Agent
       ├── Test Agent
       └── Code Review Agent

Each agent works independently while communicating through the shared
task system.

------------------------------------------------------------------------

# Why Use Agent Teams

Agent Teams help with:

## Parallel execution

Multiple agents can work simultaneously on different parts of a
codebase.

## Complex problem solving

Tasks can be decomposed into smaller subtasks handled by specialized
agents.

## Large codebases

Agents can divide responsibility across modules.

## Real team‑like workflows

Different agents can take roles similar to developers in a software
team.

------------------------------------------------------------------------

# Example Prompt

You usually do not configure teams manually.

Instead, describe the work and Claude forms the team automatically.

Example:

    Create an agent team to refactor the authentication system.

    Roles:
    - security expert
    - backend refactoring engineer
    - test writer
    - documentation writer

Claude will:

-   create the agents
-   divide the work
-   run them in parallel
-   combine the results

------------------------------------------------------------------------

# Sub‑Agents vs Agent Teams

  -----------------------------------------------------------------------
  Feature                 Sub‑Agents              Agent Teams
  ----------------------- ----------------------- -----------------------
  Execution               Within one session      Multiple sessions

  Communication           Return results to main  Agents message each
                          agent                   other

  Coordination            Main agent controls     Shared task system

  Use case                Focused subtasks        Large collaborative
                                                  tasks
  -----------------------------------------------------------------------

Sub‑agents are good for small delegations, while Agent Teams are better
for multi‑agent collaboration.

------------------------------------------------------------------------

# Enabling Agent Teams

Agent Teams may be experimental in some versions of Claude Code.

Example configuration:

    ~/.claude/settings.json

    {
      "env": {
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
      }
    }

After enabling, Claude Code can spawn teams automatically.

------------------------------------------------------------------------

# Example Use Cases

## Full‑stack feature development

Agents:

-   backend API developer
-   frontend UI developer
-   test engineer
-   code reviewer

## Codebase refactor

Agents analyze different modules simultaneously.

## Research and implementation

-   research agent gathers information
-   architect agent designs approach
-   implementation agent writes code

------------------------------------------------------------------------

# Summary

Agent Teams transform Claude Code from a single coding assistant into a
collaborative AI team.

Key benefits:

-   parallel execution
-   specialized agents
-   scalable workflows
-   team‑like development patterns
