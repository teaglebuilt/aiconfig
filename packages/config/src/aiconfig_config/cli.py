"""CLI for MCP configuration management."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from aiconfig_config.mcp import MCPConfig


def cmd_sync(args: argparse.Namespace) -> None:
    """Sync MCP config to all client locations."""
    config = MCPConfig()

    # Cursor
    cursor_path = Path(args.cursor_mcp) if args.cursor_mcp else Path.home() / ".cursor" / "mcp.json"
    config.write_cursor_config(cursor_path)
    print(f"Wrote Cursor config to {cursor_path}")

    # Claude Code
    claude_path = (
        Path(args.claude_settings)
        if args.claude_settings
        else Path.home() / ".config" / "claude-code" / "settings.json"
    )
    config.merge_claude_code_settings(claude_path)
    print(f"Merged Claude Code config into {claude_path}")


def cmd_show(args: argparse.Namespace) -> None:
    """Print generated config for a client."""
    config = MCPConfig()
    if args.client == "cursor":
        output = config.generate_cursor_config()
    elif args.client == "claude-code":
        output = config.generate_claude_code_config()
    else:
        output = {"mcpServers": config.to_mcp_servers_json()}
    json.dump(output, sys.stdout, indent=2)
    print()


def main() -> None:
    parser = argparse.ArgumentParser(prog="aiconfig-mcp", description="MCP configuration manager")
    sub = parser.add_subparsers(dest="command", required=True)

    sync_parser = sub.add_parser("sync", help="Sync MCP config to client locations")
    sync_parser.add_argument("--cursor-mcp", help="Path to Cursor mcp.json")
    sync_parser.add_argument("--claude-settings", help="Path to Claude Code settings.json")
    sync_parser.set_defaults(func=cmd_sync)

    show_parser = sub.add_parser("show", help="Print generated config")
    show_parser.add_argument("client", choices=["cursor", "claude-code", "all"], default="all", nargs="?")
    show_parser.set_defaults(func=cmd_show)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
