#!/bin/bash
# Atomic File Write Utility
# Writes files atomically using temp file + rename pattern
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
#   --lock        Acquire file lock before writing (for concurrent access)
#   --client      Client identifier for lock (default: unknown)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
USE_LOCK=false
CLIENT="unknown"
CONTENT=""

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
        --lock)
            USE_LOCK=true
            shift
            ;;
        --client)
            CLIENT="$2"
            shift 2
            ;;
        --content)
            CONTENT="$2"
            shift 2
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
    log_error "Usage: atomic-write.sh <target-file> [--validate] [--backup] [--content 'data']"
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
        exit 1
    fi
fi

# Acquire lock if requested
LOCK_ACQUIRED=false
if [ "$USE_LOCK" = true ]; then
    if "$SCRIPT_DIR/file-lock.sh" acquire "$TARGET_FILE" --client "$CLIENT" >/dev/null; then
        LOCK_ACQUIRED=true
    else
        log_error "Failed to acquire lock"
        exit 1
    fi
fi

# Create temp file in same directory (ensures same filesystem for atomic rename)
TEMP_FILE=$(mktemp "${TARGET_DIR}/.atomic-write.XXXXXX")

# Cleanup temp file and release lock on exit (in case of error)
cleanup() {
    if [ -f "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE"
    fi
    if [ "$LOCK_ACQUIRED" = true ]; then
        "$SCRIPT_DIR/file-lock.sh" release "$TARGET_FILE" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# Write content to temp file
echo "$CONTENT" > "$TEMP_FILE"

# Create backup if requested and target exists
if [ "$CREATE_BACKUP" = true ] && [ -f "$TARGET_FILE" ]; then
    cp "$TARGET_FILE" "${TARGET_FILE}.bak"
    log_info "Created backup: ${TARGET_FILE}.bak"
fi

# Atomic rename (mv is atomic on POSIX when source and dest are on same filesystem)
mv "$TEMP_FILE" "$TARGET_FILE"

# Release lock if acquired
if [ "$LOCK_ACQUIRED" = true ]; then
    "$SCRIPT_DIR/file-lock.sh" release "$TARGET_FILE" >/dev/null
fi

# Clear trap since we successfully completed
trap - EXIT

log_success "Wrote: $TARGET_FILE"
