#!/bin/bash
# Atomic File Write Utility
# Writes files atomically using temp file + rename pattern with file locking
#
# Usage:
#   echo '{"data": "value"}' | ./atomic-write.sh /path/to/file.json
#   ./atomic-write.sh /path/to/file.json < content.json
#   ./atomic-write.sh /path/to/file.json --content '{"data": "value"}'
#
# Options:
#   --validate    Validate JSON before writing (for .json files)
#   --backup      Create .bak backup before overwriting
#   --content     Provide content as argument instead of stdin
#   --no-lock     Disable file locking (use with caution)

set -e

# Get script directory for finding file-lock.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_LOCK_SCRIPT="${SCRIPT_DIR}/file-lock.sh"

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
VALIDATE_JSON=false
CREATE_BACKUP=false
CONTENT=""
USE_LOCK=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --validate)
            VALIDATE_JSON=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --content)
            CONTENT="$2"
            shift 2
            ;;
        --no-lock)
            USE_LOCK=false
            shift
            ;;
        -*)
            log_error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$TARGET_FILE" ]; then
                TARGET_FILE="$1"
            else
                log_error "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate target file argument
if [ -z "$TARGET_FILE" ]; then
    log_error "Usage: atomic-write.sh <target-file> [--validate] [--backup] [--content 'data'] [--no-lock]"
    exit 1
fi

# Get content from stdin if not provided via --content
if [ -z "$CONTENT" ]; then
    CONTENT=$(cat)
fi

# Validate content is not empty
if [ -z "$CONTENT" ]; then
    log_error "No content provided"
    exit 1
fi

# Function to perform the actual write (will be called with or without lock)
do_atomic_write() {

    # Get directory and ensure it exists
    TARGET_DIR=$(dirname "$TARGET_FILE")
    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
        log_info "Created directory: $TARGET_DIR"
    fi

    # Auto-detect JSON validation for .json files
    if [[ "$TARGET_FILE" == *.json ]]; then
        VALIDATE_JSON=true
    fi

    # Validate JSON if requested
    if [ "$VALIDATE_JSON" = true ]; then
        if ! echo "$CONTENT" | jq empty 2>/dev/null; then
            log_error "Invalid JSON content"
            return 1
        fi
    fi

    # Create temp file in same directory (ensures same filesystem for atomic rename)
    TEMP_FILE=$(mktemp "${TARGET_DIR}/.atomic-write.XXXXXX")

    # Cleanup temp file on exit (in case of error)
    cleanup() {
        if [ -f "$TEMP_FILE" ]; then
            rm -f "$TEMP_FILE"
        fi
    }
    trap cleanup RETURN

    # Write content to temp file
    echo "$CONTENT" > "$TEMP_FILE"

    # Create backup if requested and target exists
    if [ "$CREATE_BACKUP" = true ] && [ -f "$TARGET_FILE" ]; then
        cp "$TARGET_FILE" "${TARGET_FILE}.bak"
        log_info "Created backup: ${TARGET_FILE}.bak"
    fi

    # Atomic rename (mv is atomic on POSIX when source and dest are on same filesystem)
    mv "$TEMP_FILE" "$TARGET_FILE"

    # Clear trap since we successfully moved the file
    trap - RETURN

    log_success "Wrote: $TARGET_FILE"
}

# Execute write with or without locking
if [ "$USE_LOCK" = true ] && [ -x "$FILE_LOCK_SCRIPT" ]; then
    # Use file locking for concurrent access safety
    # Pass all variables and function to subshell via environment
    export TARGET_FILE CONTENT VALIDATE_JSON CREATE_BACKUP RED GREEN YELLOW NC
    export -f do_atomic_write log_error log_success log_info
    "$FILE_LOCK_SCRIPT" with "$TARGET_FILE" -- bash -c 'do_atomic_write'
else
    if [ "$USE_LOCK" = true ]; then
        log_info "File locking disabled (file-lock.sh not found or not executable)"
    fi
    # Fallback to unlocked write
    do_atomic_write
fi
