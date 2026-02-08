#!/bin/bash
# Memory File Reader
# Safely reads memory files with file locking
#
# Usage:
#   ./memory-read.sh /path/to/file.json
#   ./memory-read.sh /path/to/file.json --no-lock
#
# Options:
#   --no-lock     Disable file locking (faster but unsafe for concurrent access)
#   --raw         Output raw content without formatting

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
log_info() { echo -e "${YELLOW}[INFO]${NC} $1" >&2; }

# Parse arguments
TARGET_FILE=""
USE_LOCK=true
RAW_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-lock)
            USE_LOCK=false
            shift
            ;;
        --raw)
            RAW_OUTPUT=true
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
    log_error "Usage: memory-read.sh <target-file> [--no-lock] [--raw]"
    exit 1
fi

# Check if file exists
if [ ! -f "$TARGET_FILE" ]; then
    log_error "File not found: $TARGET_FILE"
    exit 1
fi

# Function to read the file
do_read() {
    if [ "$RAW_OUTPUT" = true ]; then
        cat "$TARGET_FILE"
    else
        # Pretty-print JSON if it's a .json file
        if [[ "$TARGET_FILE" == *.json ]] && command -v jq &>/dev/null; then
            jq '.' "$TARGET_FILE"
        else
            cat "$TARGET_FILE"
        fi
    fi
}

# Execute read with or without locking
if [ "$USE_LOCK" = true ] && [ -x "$FILE_LOCK_SCRIPT" ]; then
    # Use shared lock (multiple readers allowed, but blocks writers)
    # Note: flock -s for shared lock, but for simplicity we use exclusive lock
    # to ensure consistency with the write pattern
    "$FILE_LOCK_SCRIPT" with "$TARGET_FILE" -- bash -c "$(declare -f do_read); do_read"
else
    if [ "$USE_LOCK" = true ]; then
        log_info "File locking disabled (file-lock.sh not found or not executable)" >&2
    fi
    do_read
fi
