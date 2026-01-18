#!/bin/bash
# Initialize memory structure for a project
# Usage: ./init-project-memory.sh <project-name>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AICONFIG_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$AICONFIG_DIR/templates"
MEMORY_DIR="$AICONFIG_DIR/memory/projects"

PROJECT_NAME="${1:-}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    echo "Example: $0 my-app"
    exit 1
fi

PROJECT_MEMORY_DIR="$MEMORY_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_MEMORY_DIR" ]; then
    echo "Error: Project memory already exists at $PROJECT_MEMORY_DIR"
    exit 1
fi

echo "Creating project memory for: $PROJECT_NAME"
mkdir -p "$PROJECT_MEMORY_DIR"

# Get current date in ISO format
CREATED_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create context.json from template
sed -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
    -e "s/{{CREATED_DATE}}/$CREATED_DATE/g" \
    "$TEMPLATES_DIR/project-context.json" > "$PROJECT_MEMORY_DIR/context.json"

# Create empty sessions.json
cat > "$PROJECT_MEMORY_DIR/sessions.json" << 'EOF'
{
  "sessions": []
}
EOF

# Create empty decisions.json
cat > "$PROJECT_MEMORY_DIR/decisions.json" << 'EOF'
{
  "decisions": []
}
EOF

echo "✓ Project memory initialized at: $PROJECT_MEMORY_DIR"
echo ""
echo "Created files:"
echo "  - context.json    (project context and architecture)"
echo "  - sessions.json   (session history)"
echo "  - decisions.json  (architectural decisions)"
echo ""
echo "Next steps:"
echo "  1. Edit context.json to add your project's tech stack and architecture"
echo "  2. Link this project in your working directory:"
echo "     ln -s $PROJECT_MEMORY_DIR .aiconfig-memory"
