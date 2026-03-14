from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

import yaml


def find_project_root() -> Path:
    """Walk up from CWD to find the directory containing mcp.yaml."""
    current = Path.cwd()
    for parent in [current, *current.parents]:
        if (parent / "mcp.yaml").exists():
            return parent
    raise FileNotFoundError("Could not find mcp.yaml in any parent directory")


def _expand_env(value: Any) -> Any:
    """Recursively expand ${VAR} references in strings using the environment."""
    if isinstance(value, str):
        return os.path.expandvars(value)
    if isinstance(value, dict):
        return {k: _expand_env(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_expand_env(v) for v in value]
    return value


class MCPConfig:
    """Loads mcp.yaml and generates client-specific MCP configurations."""

    def __init__(self, config_path: Path | None = None):
        if config_path is None:
            config_path = find_project_root() / "mcp.yaml"
        self.config_path = config_path
        self._raw = self._load()

    def _load(self) -> dict[str, Any]:
        with open(self.config_path) as f:
            raw = yaml.safe_load(f) or {}
        return _expand_env(raw)

    @property
    def servers(self) -> dict[str, Any]:
        return self._raw.get("servers", {})

    def to_mcp_servers_json(self) -> dict[str, Any]:
        """Build the mcpServers object shared by all clients."""
        mcp_servers: dict[str, Any] = {}
        for name, server in self.servers.items():
            entry: dict[str, Any] = {"command": server["command"], "args": server["args"]}
            if "env" in server:
                entry["env"] = server["env"]
            mcp_servers[name] = entry
        return mcp_servers

    def generate_cursor_config(self) -> dict[str, Any]:
        """Generate .cursor/mcp.json content."""
        return {"mcpServers": self.to_mcp_servers_json()}

    def generate_claude_code_config(self) -> dict[str, Any]:
        """Generate the mcpServers block for Claude Code settings.json."""
        return {"mcpServers": self.to_mcp_servers_json()}

    def write_cursor_config(self, output_path: Path) -> None:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json.dumps(self.generate_cursor_config(), indent=2) + "\n")

    def merge_claude_code_settings(self, settings_path: Path) -> None:
        """Merge mcpServers into existing Claude Code settings.json."""
        if settings_path.exists():
            existing = json.loads(settings_path.read_text())
        else:
            existing = {}
        existing["mcpServers"] = self.to_mcp_servers_json()
        settings_path.parent.mkdir(parents=True, exist_ok=True)
        settings_path.write_text(json.dumps(existing, indent=2) + "\n")
