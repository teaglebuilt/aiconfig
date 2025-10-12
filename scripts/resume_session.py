#!/usr/bin/env python3
"""
Context Bundle Session Analyzer & Resume Helper

This script analyzes context bundles to help you resume work from a previous session.
It generates a human-readable summary that you can provide to Claude Code to resume work.

Usage:
    python resume_session.py [session_id or bundle_file]
    python resume_session.py --list              # List recent sessions
    python resume_session.py --latest            # Show latest session
    python resume_session.py SESSION_ID          # Show specific session
"""

import json
import sys
from pathlib import Path
from typing import Dict, List, Optional


def get_context_bundle_dir() -> Path:
    """Get the context_bundles directory"""
    context_dir = Path.home() / ".claude" / "context_bundles"
    return context_dir


def list_sessions() -> List[Dict]:
    """List all available sessions sorted by date"""
    context_dir = get_context_bundle_dir()
    sessions = []

    for bundle_file in context_dir.glob("*.json"):
        try:
            with open(bundle_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                sessions.append(
                    {
                        "file": bundle_file,
                        "session_id": data.get("session_id", "unknown"),
                        "created_at": data.get("created_at"),
                        "last_updated": data.get("last_updated"),
                        "operation_count": len(data.get("operations", [])),
                    }
                )
        except Exception as e:
            print(f"Error reading {bundle_file}: {e}", file=sys.stderr)

    # Sort by last_updated descending
    sessions.sort(key=lambda x: x.get("last_updated", ""), reverse=True)
    return sessions


def load_bundle(identifier: str) -> Optional[Dict]:
    """Load a bundle by session_id or file path"""
    context_dir = get_context_bundle_dir()

    # Check if it's a file path
    bundle_path = Path(identifier)
    if bundle_path.exists():
        with open(bundle_path, "r", encoding="utf-8") as f:
            return json.load(f), bundle_path

    # Try to find by session_id (partial match)
    for bundle_file in context_dir.glob("*.json"):
        if identifier in bundle_file.name:
            with open(bundle_file, "r", encoding="utf-8") as f:
                return json.load(f), bundle_file

    return None, None


def analyze_bundle(bundle: Dict) -> Dict:
    """Analyze a context bundle and extract key information"""
    operations = bundle.get("operations", [])

    analysis = {
        "session_id": bundle.get("session_id"),
        "created_at": bundle.get("created_at"),
        "last_updated": bundle.get("last_updated"),
        "total_operations": len(operations),
        "files_modified": set(),
        "files_read": set(),
        "files_created": set(),
        "bash_commands": [],
        "agents_used": set(),
        "searches_performed": [],
        "todos_written": 0,
        "web_activities": [],
        "operation_timeline": [],
    }

    for op in operations:
        op_type = op.get("operation", "unknown")
        timestamp = op.get("timestamp", "")

        # Track files
        if op_type == "read":
            file_path = op.get("file_path")
            if file_path:
                analysis["files_read"].add(file_path)

        elif op_type == "edit":
            file_path = op.get("file_path")
            if file_path:
                analysis["files_modified"].add(file_path)

        elif op_type == "write":
            file_path = op.get("file_path")
            if file_path:
                analysis["files_created"].add(file_path)

        # Track bash commands
        elif op_type == "bash":
            command = op.get("command", "")
            description = op.get("description", "")
            analysis["bash_commands"].append(
                {"command": command, "description": description, "timestamp": timestamp}
            )

        # Track agents
        elif op_type == "task":
            subagent = op.get("subagent_type", "unknown")
            analysis["agents_used"].add(subagent)

        # Track searches
        elif op_type in ["glob", "grep"]:
            pattern = op.get("pattern", "")
            path = op.get("path", ".")
            analysis["searches_performed"].append(
                {
                    "type": op_type,
                    "pattern": pattern,
                    "path": path,
                    "timestamp": timestamp,
                }
            )

        # Track todos
        elif op_type == "todowrite":
            analysis["todos_written"] += op.get("todo_count", 0)

        # Track web activities
        elif op_type in ["webfetch", "websearch"]:
            analysis["web_activities"].append(
                {
                    "type": op_type,
                    "url": op.get("url", op.get("query", "")),
                    "timestamp": timestamp,
                }
            )

        # Build timeline (last 10 operations)
        analysis["operation_timeline"].append(
            {
                "operation": op_type,
                "timestamp": timestamp,
                "details": {
                    k: v for k, v in op.items() if k not in ["operation", "timestamp"]
                },
            }
        )

    # Keep only last 15 timeline items for brevity
    analysis["operation_timeline"] = analysis["operation_timeline"][-15:]

    return analysis


def format_resume_prompt(analysis: Dict, bundle_path: Path) -> str:
    """Format the analysis into a Claude-friendly resume prompt"""

    lines = []
    lines.append("# Session Context Resume")
    lines.append("")
    lines.append(f"**Bundle File:** `{bundle_path.name}`")
    lines.append(f"**Session ID:** `{analysis['session_id']}`")
    lines.append(f"**Created:** {analysis['created_at']}")
    lines.append(f"**Last Updated:** {analysis['last_updated']}")
    lines.append(f"**Total Operations:** {analysis['total_operations']}")
    lines.append("")

    # Files section
    if analysis["files_created"]:
        lines.append("## Files Created")
        for file_path in sorted(analysis["files_created"]):
            lines.append(f"- `{file_path}`")
        lines.append("")

    if analysis["files_modified"]:
        lines.append("## Files Modified")
        for file_path in sorted(analysis["files_modified"]):
            lines.append(f"- `{file_path}`")
        lines.append("")

    if analysis["files_read"]:
        lines.append("## Files Read")
        # Show only first 10 to avoid overwhelming
        files_to_show = sorted(analysis["files_read"])[:10]
        for file_path in files_to_show:
            lines.append(f"- `{file_path}`")
        if len(analysis["files_read"]) > 10:
            lines.append(f"- ... and {len(analysis['files_read']) - 10} more files")
        lines.append("")

    # Agents used
    if analysis["agents_used"]:
        lines.append("## Agents Used")
        for agent in sorted(analysis["agents_used"]):
            lines.append(f"- `{agent}`")
        lines.append("")

    # Key commands
    if analysis["bash_commands"]:
        lines.append("## Key Bash Commands")
        for cmd in analysis["bash_commands"][-5:]:  # Last 5 commands
            if cmd["description"]:
                lines.append(f"- `{cmd['command']}` - {cmd['description']}")
            else:
                lines.append(f"- `{cmd['command']}`")
        lines.append("")

    # Searches
    if analysis["searches_performed"]:
        lines.append("## Searches Performed")
        for search in analysis["searches_performed"][-5:]:  # Last 5 searches
            lines.append(
                f"- {search['type']}: `{search['pattern']}` in `{search['path']}`"
            )
        lines.append("")

    # Web activities
    if analysis["web_activities"]:
        lines.append("## Web Activities")
        for activity in analysis["web_activities"][-5:]:
            lines.append(f"- {activity['type']}: `{activity['url']}`")
        lines.append("")

    # Recent timeline
    lines.append("## Recent Operation Timeline")
    for item in analysis["operation_timeline"]:
        timestamp = item["timestamp"].split("T")[1][:8]  # Just time portion
        op = item["operation"]

        # Create a brief summary
        details = item["details"]
        if "file_path" in details:
            summary = f"`{details['file_path']}`"
        elif "command" in details:
            summary = (
                f"`{details['command'][:50]}...`"
                if len(details["command"]) > 50
                else f"`{details['command']}`"
            )
        elif "pattern" in details:
            summary = f"pattern: `{details['pattern']}`"
        elif "subagent_type" in details:
            summary = f"agent: `{details['subagent_type']}`"
        else:
            summary = str(details)[:50]

        lines.append(f"- [{timestamp}] **{op}** - {summary}")

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append(
        "**How to use this:** Copy this summary and provide it to Claude Code with a message like:"
    )
    lines.append(
        "> 'Here's the context from my previous session. I'd like to continue where I left off...'"
    )

    return "\n".join(lines)


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help"]:
        print(__doc__)
        return

    command = sys.argv[1]

    # List sessions
    if command == "--list":
        sessions = list_sessions()
        print("\n=== Recent Sessions ===\n")
        for i, session in enumerate(sessions[:10], 1):
            created = (
                session["created_at"].split("T")[0]
                if session["created_at"]
                else "unknown"
            )
            print(f"{i}. {session['file'].name}")
            print(f"   Session ID: {session['session_id'][:16]}...")
            print(f"   Created: {created}")
            print(f"   Operations: {session['operation_count']}")
            print()
        return

    # Show latest session
    if command == "--latest":
        sessions = list_sessions()
        if not sessions:
            print("No sessions found")
            return

        latest = sessions[0]
        bundle, bundle_path = load_bundle(str(latest["file"]))
        if not bundle:
            print("Error loading latest session")
            return

        analysis = analyze_bundle(bundle)
        print(format_resume_prompt(analysis, bundle_path))
        return

    # Load specific session
    bundle, bundle_path = load_bundle(command)
    if not bundle:
        print(f"Session not found: {command}")
        print("\nTry: python resume_session.py --list")
        return

    analysis = analyze_bundle(bundle)
    print(format_resume_prompt(analysis, bundle_path))


if __name__ == "__main__":
    main()
