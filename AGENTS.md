# AGENTS

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: `npx openskills read <skill-name>` (run in your shell)
  - For multiple: `npx openskills read skill-one,skill-two`
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>generate-prd</name>
<description>'Generate a Product Requirements Document (PRD) for a new feature. Use when planning a feature, starting a new project, or when asked to create a PRD. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out.'</description>
<location>project</location>
</skill>

<skill>
<name>generate-prd-to-json</name>
<description>"Convert PRDs to prd.json format for the Ralph autonomous agent system plugin. Use when you have an existing PRD and need to convert it to Ralph's JSON format. Triggers on: convert this prd, turn this into ralph format, create prd.json from this, ralph json."</description>
<location>project</location>
</skill>

<skill>
<name>init-memory</name>
<description>"Initialize project memory for the current project. Creates context.json, sessions.json, and decisions.json. Triggers on: init memory, setup memory, initialize project memory, start tracking this project."</description>
<location>project</location>
</skill>

<skill>
<name>kubernetes-arch</name>
<description></description>
<location>project</location>
</skill>

<skill>
<name>log-session</name>
<description>"Log the current coding session to project memory. Use at the end of a session to record accomplishments, decisions, and follow-ups. Triggers on: log this session, save session, end session, record what we did."</description>
<location>project</location>
</skill>

<skill>
<name>recall</name>
<description>"Search project memory for relevant context. Use to find past decisions, similar problems, or session history. Triggers on: recall, remember, what did we decide, find in memory, search memory, past sessions."</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
