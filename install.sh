#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CLAUDE_DIR="$SCRIPT_DIR/.claude"

echo -e "${GREEN}Claude AI Workspace Installer${NC}"
echo "=============================="

# Function to detect shell
detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    else
        # Fallback to checking $SHELL
        case "$SHELL" in
            */zsh) echo "zsh" ;;
            */bash) echo "bash" ;;
            *) echo "unknown" ;;
        esac
    fi
}

# Function to get shell config file
get_shell_config() {
    local shell_type="$1"
    case "$shell_type" in
        "zsh")
            echo "$HOME/.zshrc"
            ;;
        "bash")
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Function to check Node.js version
check_node_version() {
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Error: Node.js is not installed or not in PATH${NC}"
        echo "Please install Node.js version 18 or later from https://nodejs.org/"
        exit 1
    fi
    
    local node_version=$(node -v | sed 's/v//')
    local major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [[ "$major_version" -lt 18 ]]; then
        echo -e "${RED}Error: Node.js version $node_version is too old${NC}"
        echo "Claude requires Node.js version 18 or later. Current version: v$node_version"
        echo "Please upgrade Node.js from https://nodejs.org/"
        exit 1
    fi
    
    echo -e "${GREEN}✓${NC} Node.js version v$node_version (meets requirement >= 18)"
}

# Function to install Claude code package
install_claude_code() {
    echo "Installing Claude code package..."
    if npm list -g @anthropic-ai/claude-code &> /dev/null; then
        echo -e "${YELLOW}Claude Code already installed${NC}"
    else
        echo "Installing Claude Code globally..."
        if npm install -g @anthropic-ai/claude-code; then
            echo -e "${GREEN}✓${NC} Claude Code installed successfully"
        else
            echo -e "${RED}Warning: Failed to install Claude Code${NC}"
            echo "You may need to install it manually with: npm install -g @anthropic-ai/claude-code"
        fi
    fi
}

# Check if .claude directory exists
if [[ ! -d "$CLAUDE_DIR" ]]; then
    echo -e "${RED}Error: .claude directory not found at $CLAUDE_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Installing Claude AI Workspace...${NC}"

# 1. Check Node.js version
echo "Checking Node.js version..."
check_node_version

# 2. Create symlink to ~/.claude
echo "Setting up ~/.claude symlink..."
if [[ -L "$HOME/.claude" ]]; then
    echo "Removing existing ~/.claude symlink..."
    rm "$HOME/.claude"
elif [[ -d "$HOME/.claude" ]]; then
    echo -e "${YELLOW}Warning: ~/.claude directory already exists. Backing up to ~/.claude.backup${NC}"
    mv "$HOME/.claude" "$HOME/.claude.backup"
fi

ln -sf "$CLAUDE_DIR" "$HOME/.claude"
echo -e "${GREEN}✓${NC} Created symlink: ~/.claude -> $CLAUDE_DIR"

# 3. Add to PATH
SHELL_TYPE=$(detect_shell)
echo "Detected shell: $SHELL_TYPE"

# Add to both zsh and bash configs if they exist or if they're the current shell
PATH_EXPORT="export PATH=\"$SCRIPT_DIR:\$PATH\""
CONFIGS_UPDATED=()

# Always try to update .zshrc if it exists or if we're using zsh
if [[ "$SHELL_TYPE" == "zsh" ]] || [[ -f "$HOME/.zshrc" ]]; then
    ZSHRC="$HOME/.zshrc"
    if grep -Fxq "$PATH_EXPORT" "$ZSHRC" 2>/dev/null; then
        echo -e "${YELLOW}PATH already configured in $ZSHRC${NC}"
    else
        echo "Adding $SCRIPT_DIR to PATH in $ZSHRC..."
        touch "$ZSHRC"  # Create if it doesn't exist
        echo "" >> "$ZSHRC"
        echo "# Claude AI Workspace" >> "$ZSHRC"
        echo "$PATH_EXPORT" >> "$ZSHRC"
        echo -e "${GREEN}✓${NC} Added to PATH in $ZSHRC"
        CONFIGS_UPDATED+=("$ZSHRC")
    fi
fi

# Handle bash configs
if [[ "$SHELL_TYPE" == "bash" ]] || [[ -f "$HOME/.bashrc" ]] || [[ -f "$HOME/.bash_profile" ]]; then
    BASH_CONFIG=$(get_shell_config "bash")
    if grep -Fxq "$PATH_EXPORT" "$BASH_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}PATH already configured in $BASH_CONFIG${NC}"
    else
        echo "Adding $SCRIPT_DIR to PATH in $BASH_CONFIG..."
        touch "$BASH_CONFIG"  # Create if it doesn't exist
        echo "" >> "$BASH_CONFIG"
        echo "# Claude AI Workspace" >> "$BASH_CONFIG"
        echo "$PATH_EXPORT" >> "$BASH_CONFIG"
        echo -e "${GREEN}✓${NC} Added to PATH in $BASH_CONFIG"
        CONFIGS_UPDATED+=("$BASH_CONFIG")
    fi
fi

# 4. Install Claude code package
install_claude_code

# 5. Make any executable files in the workspace executable
echo "Setting up executable permissions..."
find "$SCRIPT_DIR" -name "*.sh" -exec chmod +x {} \;
if [[ -f "$SCRIPT_DIR/claude" ]]; then
    chmod +x "$SCRIPT_DIR/claude"
fi

echo ""
echo -e "${GREEN}Installation completed successfully!${NC}"
echo ""
echo "To start using Claude AI Workspace:"
if [[ ${#CONFIGS_UPDATED[@]} -gt 0 ]]; then
    echo "1. Restart your terminal or source your updated config file(s):"
    for config in "${CONFIGS_UPDATED[@]}"; do
        echo "   source $config"
    done
else
    echo "1. Restart your terminal"
fi
echo "2. The .claude directory is now available at ~/.claude"
echo "3. This directory is now in your PATH"
echo "4. Claude Code is installed and available globally"
echo ""
echo -e "${YELLOW}Note: You may need to restart your terminal for PATH changes to take effect.${NC}" 