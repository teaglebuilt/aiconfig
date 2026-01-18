# Session End Hook

When ending a coding session, update the project memory.

## Auto-Log Session

Before the user ends the session, offer to log the session:

```
Would you like me to log this session to memory?

I'll record:
- Summary of what we accomplished
- Files modified
- Decisions made
- Follow-up tasks
```

## Session Log Format

Add to `~/aiconfig/memory/projects/{project}/sessions.json`:

```json
{
  "id": "session-YYYYMMDD-HHMMSS",
  "date": "2025-01-18",
  "client": "claude-code",
  "summary": "Brief description of what was accomplished",
  "files_modified": [
    "src/components/Auth.tsx",
    "src/hooks/useAuth.ts"
  ],
  "decisions_made": [
    "Used Zod for form validation",
    "Chose JWT over session cookies"
  ],
  "follow_up": [
    "Add unit tests for auth hook",
    "Implement refresh token rotation"
  ],
  "tags": ["auth", "feature"]
}
```

## Decision Recording

If architectural decisions were made, add to `decisions.json`:

```json
{
  "id": "decision-YYYYMMDD-001",
  "date": "2025-01-18",
  "title": "Use Zod for runtime validation",
  "context": "Need form validation that integrates with TypeScript",
  "decision": "Use Zod for schema validation",
  "rationale": "Type-safe, good DX, generates TS types automatically",
  "alternatives_considered": ["Yup", "Joi", "manual validation"],
  "status": "accepted"
}
```

## Context Update

Update `context.json` if:
- Current focus changed
- New known issues discovered
- Architecture evolved
- Active branches changed
