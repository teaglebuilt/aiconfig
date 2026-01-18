#!/bin/bash
# AIConfig Installation Script
# Sets up shared AI configuration for Claude Code and Cursor
#
# Usage: ./install.sh [--uninstall]
#
# This script:
# 1. Creates symlinks from $HOME/.claude and $HOME/.cursor to aiconfig
# 2. Backs up existing configurations
# 3. Sets up MCP server configuration for Claude Code
# 4. Configures environment variables

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AICONFIG_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$HOME/.aiconfig-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Uninstall ---
if [ "$1" = "--uninstall" ]; then
    log_info "Uninstalling aiconfig..."

    # Remove symlinks
    [ -L "$HOME/.claude" ] && rm "$HOME/.claude" && log_info "Removed ~/.claude symlink"
    [ -L "$HOME/.cursor" ] && rm "$HOME/.cursor" && log_info "Removed ~/.cursor symlink"
    [ -L "$HOME/aiconfig" ] && rm "$HOME/aiconfig" && log_info "Removed ~/aiconfig symlink"

    # Check for backups
    if ls "$HOME"/.aiconfig-backup-* 1>/dev/null 2>&1; then
        log_info "Backups found. Restore manually if needed:"
        ls -d "$HOME"/.aiconfig-backup-*
    fi

    log_info "Uninstall complete. Remove AICONFIG_PATH from your shell profile manually."
    exit 0
fi

# --- Pre-flight checks ---
log_info "AIConfig Installation"
log_info "Source: $AICONFIG_DIR"
echo ""

# Check if aiconfig directory exists
if [ ! -d "$AICONFIG_DIR" ]; then
    log_error "AIConfig directory not found: $AICONFIG_DIR"
    exit 1
fi

# --- Backup existing configs ---
backup_if_exists() {
    local target="$1"
    local name="$2"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$name"
        log_warn "Backed up existing $target to $BACKUP_DIR/$name"
    elif [ -L "$target" ]; then
        rm "$target"
        log_info "Removed existing symlink: $target"
    fi
}

backup_if_exists "$HOME/.claude" ".claude"
backup_if_exists "$HOME/.cursor" ".cursor"

# --- Create symlinks ---
log_info "Creating symlinks..."

# Main aiconfig symlink
if [ ! -L "$HOME/aiconfig" ]; then
    ln -s "$AICONFIG_DIR" "$HOME/aiconfig"
    log_info "Created ~/aiconfig -> $AICONFIG_DIR"
else
    log_info "~/aiconfig symlink already exists"
fi

# Claude Code config
if [ -d "$AICONFIG_DIR/.claude" ]; then
    ln -s "$AICONFIG_DIR/.claude" "$HOME/.claude"
    log_info "Created ~/.claude -> $AICONFIG_DIR/.claude"
else
    log_warn ".claude directory not found in aiconfig, skipping"
fi

# Cursor config
if [ -d "$AICONFIG_DIR/.cursor" ]; then
    ln -s "$AICONFIG_DIR/.cursor" "$HOME/.cursor"
    log_info "Created ~/.cursor -> $AICONFIG_DIR/.cursor"
else
    log_warn ".cursor directory not found in aiconfig, skipping"
fi

# --- Setup Claude Code MCP ---
log_info "Setting up Claude Code MCP configuration..."

CLAUDE_SETTINGS_DIR="$HOME/.config/claude-code"
CLAUDE_SETTINGS_FILE="$CLAUDE_SETTINGS_DIR/settings.json"

mkdir -p "$CLAUDE_SETTINGS_DIR"

# Check if settings.json exists and merge MCP config
if [ -f "$CLAUDE_SETTINGS_FILE" ]; then
    log_info "Existing Claude Code settings found. Please manually merge MCP config from:"
    log_info "  $AICONFIG_DIR/mcp-config/claude-code.json"
else
    # Create initial settings with MCP servers
    cat > "$CLAUDE_SETTINGS_FILE" << 'EOF'
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    },
    "lancedb": {
      "command": "uvx",
      "args": ["lancedb-mcp"],
      "env": {
        "LANCEDB_URI": "$HOME/aiconfig/memory/vectors/lancedb",
        "LANCEDB_TABLE": "aiconfig_embeddings"
      }
    }
  }
}
EOF
    log_info "Created Claude Code settings with MCP servers"
fi

# --- Setup Cursor MCP ---
log_info "Setting up Cursor MCP configuration..."

CURSOR_MCP_FILE="$HOME/.cursor/mcp.json"

if [ -f "$CURSOR_MCP_FILE" ]; then
    log_info "Existing Cursor MCP config found. Please manually merge from:"
    log_info "  $AICONFIG_DIR/mcp-config/cursor.json"
else
    # Create Cursor MCP config
    cat > "$CURSOR_MCP_FILE" << 'EOF'
{
  "mcpServers": {
    "basic-memory": {
      "command": "uvx",
      "args": ["basic-memory", "mcp"]
    },
    "lancedb": {
      "command": "uvx",
      "args": ["lancedb-mcp"],
      "env": {
        "LANCEDB_URI": "~/aiconfig/memory/vectors/lancedb",
        "LANCEDB_TABLE": "aiconfig_embeddings"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-filesystem", "~/aiconfig"]
    }
  }
}
EOF
    log_info "Created Cursor MCP config at ~/.cursor/mcp.json"
fi

# --- Environment setup ---
log_info "Environment setup..."

SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
fi

ENV_EXPORT="export AICONFIG_PATH=\"$HOME/aiconfig\""

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "AICONFIG_PATH" "$SHELL_PROFILE" 2>/dev/null; then
        echo "" >> "$SHELL_PROFILE"
        echo "# AIConfig - Shared AI coding configuration" >> "$SHELL_PROFILE"
        echo "$ENV_EXPORT" >> "$SHELL_PROFILE"
        log_info "Added AICONFIG_PATH to $SHELL_PROFILE"
    else
        log_info "AICONFIG_PATH already in $SHELL_PROFILE"
    fi
else
    log_warn "Could not find shell profile. Add manually:"
    echo "  $ENV_EXPORT"
fi

# --- Install dependencies ---
echo ""
log_info "Optional: Install MCP server dependencies"
echo "  pip install basic-memory lancedb lancedb-mcp"
echo ""

# --- Summary ---
echo ""
log_info "Installation complete!"
echo ""
echo "Created:"
echo "  ~/aiconfig        -> $AICONFIG_DIR"
echo "  ~/.claude         -> $AICONFIG_DIR/.claude"
echo "  ~/.cursor         -> $AICONFIG_DIR/.cursor"
echo ""
echo "Includes:"
echo "  - Skills:  ~/.claude/skills/, ~/.cursor/skills/"
echo "  - Agents:  ~/.claude/agents/, ~/.cursor/agents/"
echo "  - Rules:   ~/.cursor/rules/"
echo "  - Memory:  ~/aiconfig/memory/"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: source $SHELL_PROFILE)"
echo "  2. Install MCP dependencies: pip install basic-memory lancedb lancedb-mcp"
echo "  3. Initialize project memory: ~/aiconfig/scripts/init-project-memory.sh <project>"
echo "  4. Use /init-memory, /log-session, /recall skills in Claude or Cursor"
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
