#!/bin/bash
# Memory File Updater
# Safely updates JSON memory files with file locking and atomic writes
#
# Usage:
#   # Update using jq expression
#   ./memory-update.sh /path/to/file.json '.sessions += [{"id": "new"}]'
#
#   # Read, modify, write pattern
#   ./memory-update.sh /path/to/file.json --function update_function
#
# Options:
#   --backup      Create backup before updating
#   --function    Custom bash function to update (receives JSON on stdin, outputs on stdout)

set -e

# Get script directory for finding other scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_LOCK_SCRIPT="${SCRIPT_DIR}/file-lock.sh"
ATOMIC_WRITE_SCRIPT="${SCRIPT_DIR}/atomic-write.sh"
MEMORY_READ_SCRIPT="${SCRIPT_DIR}/memory-read.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1" >&2; }

# Parse arguments
TARGET_FILE=""
JQ_EXPRESSION=""
UPDATE_FUNCTION=""
CREATE_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --function)
            UPDATE_FUNCTION="$2"
            shift 2
            ;;
        -*)
            log_error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$TARGET_FILE" ]; then
                TARGET_FILE="$1"
            elif [ -z "$JQ_EXPRESSION" ] && [ -z "$UPDATE_FUNCTION" ]; then
                JQ_EXPRESSION="$1"
            else
                log_error "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "$TARGET_FILE" ]; then
    log_error "Usage: memory-update.sh <file> <jq-expression> [--backup]"
    log_error "   or: memory-update.sh <file> --function <function-name> [--backup]"
    exit 1
fi

if [ -z "$JQ_EXPRESSION" ] && [ -z "$UPDATE_FUNCTION" ]; then
    log_error "Must provide either jq expression or --function"
    exit 1
fi

# Check if file exists
if [ ! -f "$TARGET_FILE" ]; then
    log_error "File not found: $TARGET_FILE"
    exit 1
fi

# Validate file is JSON
if [[ "$TARGET_FILE" != *.json ]]; then
    log_error "File must be .json: $TARGET_FILE"
    exit 1
fi

# Function to update the file
do_update() {
    local temp_output

    # Read current content with lock
    local current_content=$("$MEMORY_READ_SCRIPT" "$TARGET_FILE" --raw --no-lock)

    # Apply transformation
    if [ -n "$JQ_EXPRESSION" ]; then
        # Use jq to transform
        temp_output=$(echo "$current_content" | jq "$JQ_EXPRESSION")
    elif [ -n "$UPDATE_FUNCTION" ]; then
        # Use custom function
        if ! declare -f "$UPDATE_FUNCTION" &>/dev/null; then
            log_error "Function not found: $UPDATE_FUNCTION"
            return 1
        fi
        temp_output=$(echo "$current_content" | "$UPDATE_FUNCTION")
    fi

    # Validate output is valid JSON
    if ! echo "$temp_output" | jq empty 2>/dev/null; then
        log_error "Update produced invalid JSON"
        return 1
    fi

    # Write atomically (without lock, as we're already in a locked context)
    local backup_flag=""
    if [ "$CREATE_BACKUP" = true ]; then
        backup_flag="--backup"
    fi

    echo "$temp_output" | "$ATOMIC_WRITE_SCRIPT" "$TARGET_FILE" $backup_flag --no-lock
}

# Execute update with file lock
if [ -x "$FILE_LOCK_SCRIPT" ]; then
    # Export all necessary variables and functions
    export TARGET_FILE JQ_EXPRESSION UPDATE_FUNCTION CREATE_BACKUP
    export MEMORY_READ_SCRIPT ATOMIC_WRITE_SCRIPT
    export RED GREEN YELLOW NC
    export -f do_update log_error log_success log_info

    "$FILE_LOCK_SCRIPT" with "$TARGET_FILE" -- bash -c 'do_update'
else
    log_error "File locking not available (file-lock.sh not found)"
    exit 1
fi

log_success "Updated: $TARGET_FILE"
