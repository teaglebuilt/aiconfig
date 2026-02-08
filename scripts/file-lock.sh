#!/bin/bash
# File Locking Utility
# Provides OS-level file locking for concurrent client access
#
# Usage:
#   # Acquire lock and run command
#   ./file-lock.sh acquire /path/to/file.json -- command args
#
#   # Manual lock/unlock
#   LOCK_FD=$(./file-lock.sh acquire /path/to/file.json)
#   # ... do work ...
#   ./file-lock.sh release "$LOCK_FD"
#
# Features:
#   - Portable file locking (works on Linux and macOS)
#   - Automatic timeout and retry
#   - Clean lock file management
#   - Process crash recovery
#
# Implementation:
#   - Linux: Uses flock if available
#   - macOS/BSD: Uses shlock or mkdir-based locking
#
# Environment Variables:
#   LOCK_TIMEOUT    - Max seconds to wait for lock (default: 30)
#   LOCK_RETRY      - Retry interval in seconds (default: 0.1)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() { echo -e "${RED}[LOCK ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[LOCK OK]${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}[LOCK INFO]${NC} $1" >&2; }
log_debug() {
    if [ "${LOCK_DEBUG:-0}" = "1" ]; then
        echo -e "${BLUE}[LOCK DEBUG]${NC} $1" >&2
    fi
}

# Default configuration
LOCK_TIMEOUT="${LOCK_TIMEOUT:-30}"
LOCK_RETRY="${LOCK_RETRY:-0.1}"

# Lock file directory (stores .lock files)
LOCK_DIR="${AICONFIG_PATH:-$HOME/aiconfig}/.locks"

# Ensure lock directory exists
mkdir -p "$LOCK_DIR"

# Detect if flock is available (Linux) or fall back to mkdir-based locking (macOS)
has_flock() {
    command -v flock &>/dev/null
}

# Get lock file path for a target file
get_lock_file() {
    local target_file="$1"
    local target_basename=$(basename "$target_file")
    local target_dirname=$(dirname "$target_file")

    # Create a unique lock file name based on full path
    # Use base64 to safely encode the full path (use shasum for portability if base64 issues)
    local encoded_path=$(echo -n "$target_file" | shasum -a 256 | cut -d' ' -f1)
    echo "${LOCK_DIR}/${encoded_path}.lock"
}

# Portable lock acquisition using mkdir (atomic on POSIX)
acquire_lock_mkdir() {
    local lock_file="$1"
    local timeout_ms="$2"
    local retry_ms="$3"

    local elapsed_ms=0

    # Try to create lock directory atomically
    while [ "$elapsed_ms" -lt "$timeout_ms" ]; do
        # mkdir is atomic - if it succeeds, we got the lock
        if mkdir "$lock_file" 2>/dev/null; then
            # Write lock info
            echo "PID: $$" > "$lock_file/info"
            echo "ACQUIRED: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$lock_file/info"
            echo "HOSTNAME: $(hostname)" >> "$lock_file/info"
            return 0
        fi

        # Check if lock is stale (process doesn't exist)
        if [ -f "$lock_file/info" ]; then
            local lock_pid=$(grep "^PID: " "$lock_file/info" 2>/dev/null | cut -d' ' -f2)
            if [ -n "$lock_pid" ] && ! kill -0 "$lock_pid" 2>/dev/null; then
                # Process is dead, remove stale lock
                log_debug "Removing stale lock from PID $lock_pid"
                rm -rf "$lock_file"
                continue
            fi
        fi

        # Wait and retry
        sleep "$LOCK_RETRY"
        elapsed_ms=$((elapsed_ms + retry_ms))
    done

    return 1
}

# Portable lock release for mkdir-based locks
release_lock_mkdir() {
    local lock_file="$1"

    # Only remove if we own it
    if [ -f "$lock_file/info" ]; then
        local lock_pid=$(grep "^PID: " "$lock_file/info" 2>/dev/null | cut -d' ' -f2)
        if [ "$lock_pid" = "$$" ]; then
            rm -rf "$lock_file"
            return 0
        else
            log_error "Cannot release lock owned by PID $lock_pid (we are $$)"
            return 1
        fi
    fi

    return 1
}

# Portable lock check
is_lock_held() {
    local lock_file="$1"
    [ -d "$lock_file" ]
}

# Acquire a file lock
# Returns: Lock identifier (lock file path)
# Exits with error if lock cannot be acquired within timeout
acquire_lock() {
    local target_file="$1"
    local lock_file=$(get_lock_file "$target_file")

    log_debug "Acquiring lock for: $target_file"
    log_debug "Lock file: $lock_file"

    # Convert to milliseconds for integer arithmetic
    local timeout_ms=$((LOCK_TIMEOUT * 1000))
    local retry_ms=$(echo "$LOCK_RETRY * 1000 / 1" | bc 2>/dev/null || echo "100")

    # Use portable mkdir-based locking (works on Linux and macOS)
    if acquire_lock_mkdir "$lock_file" "$timeout_ms" "$retry_ms"; then
        log_debug "Lock acquired: $lock_file"
        # Return the lock file path as the lock identifier
        echo "$lock_file"
        return 0
    else
        log_error "Failed to acquire lock for $target_file after ${LOCK_TIMEOUT}s"
        log_error "Another process may be holding the lock. Check for stale locks in: $LOCK_DIR"

        # Show lock file contents for debugging
        if [ -f "$lock_file/info" ]; then
            log_info "Lock file contents:"
            cat "$lock_file/info" >&2 || true
        fi

        return 1
    fi
}

# Release a file lock
release_lock() {
    local lock_file="$1"

    if [ -z "$lock_file" ]; then
        log_error "No lock file provided to release"
        return 1
    fi

    log_debug "Releasing lock: $lock_file"

    # Use portable lock release
    if release_lock_mkdir "$lock_file"; then
        log_debug "Lock released"
        return 0
    else
        return 1
    fi
}

# Execute a command with a lock held
with_lock() {
    local target_file="$1"
    shift

    log_debug "Executing with lock: $*"

    # Acquire lock
    local lock_file
    lock_file=$(acquire_lock "$target_file") || return 1

    # Setup cleanup trap to ensure lock is released
    trap "release_lock '$lock_file'" EXIT INT TERM

    # Execute the command
    local exit_code=0
    "$@" || exit_code=$?

    # Release lock
    release_lock "$lock_file"
    trap - EXIT INT TERM

    return $exit_code
}

# Clean up stale locks (locks from dead processes)
cleanup_stale_locks() {
    log_info "Checking for stale locks in: $LOCK_DIR"

    local cleaned=0

    # Find all lock directories
    find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | while read -r lock_file; do
        # Check if lock is from a dead process
        if [ -f "$lock_file/info" ]; then
            local lock_pid=$(grep "^PID: " "$lock_file/info" 2>/dev/null | cut -d' ' -f2)

            if [ -n "$lock_pid" ] && ! kill -0 "$lock_pid" 2>/dev/null; then
                log_info "Removing stale lock from dead process PID $lock_pid"
                rm -rf "$lock_file"
                cleaned=$((cleaned + 1))
            fi
        else
            # Lock directory with no info file is likely corrupt
            log_info "Removing corrupt lock directory: $lock_file"
            rm -rf "$lock_file"
            cleaned=$((cleaned + 1))
        fi
    done

    if [ "$cleaned" -gt 0 ]; then
        log_success "Cleaned $cleaned stale lock(s)"
    else
        log_info "No stale locks found"
    fi
}

# Show current locks
show_locks() {
    echo "Current locks in: $LOCK_DIR"
    echo ""

    local lock_count=0

    find "$LOCK_DIR" -name "*.lock" -type d 2>/dev/null | while read -r lock_file; do
        lock_count=$((lock_count + 1))
        local basename=$(basename "$lock_file" .lock)

        echo "Lock: $lock_file"

        # Try to read lock info
        if [ -f "$lock_file/info" ]; then
            echo "  Info:"
            sed 's/^/    /' "$lock_file/info"

            # Check if process is alive
            local lock_pid=$(grep "^PID: " "$lock_file/info" 2>/dev/null | cut -d' ' -f2)
            if [ -n "$lock_pid" ]; then
                if kill -0 "$lock_pid" 2>/dev/null; then
                    echo "  Status: ACTIVE (process $lock_pid is running)"
                else
                    echo "  Status: STALE (process $lock_pid is dead)"
                fi
            fi
        else
            echo "  Status: CORRUPT (no info file)"
        fi

        echo ""
    done

    if [ "$lock_count" -eq 0 ]; then
        echo "No locks found"
    fi
}

# Main command dispatcher
main() {
    local command="${1:-}"

    if [ -z "$command" ]; then
        cat >&2 <<EOF
File Locking Utility

Usage:
  $0 acquire <target-file>              - Acquire lock and return lock ID
  $0 release <lock-id>                  - Release lock by ID
  $0 with <target-file> -- <command>    - Execute command with lock
  $0 cleanup                            - Remove stale locks
  $0 show                               - Show current locks
  $0 help                               - Show this help

Examples:
  # Execute atomic write with lock
  $0 with /path/to/file.json -- ~/aiconfig/scripts/atomic-write.sh /path/to/file.json

  # Manual lock/unlock
  LOCK_ID=\$($0 acquire /path/to/file.json)
  # ... do work ...
  $0 release "\$LOCK_ID"

Environment:
  LOCK_TIMEOUT    - Max seconds to wait (default: 30)
  LOCK_RETRY      - Retry interval (default: 0.1)
  LOCK_DEBUG      - Enable debug output (0/1)
  AICONFIG_PATH   - AIConfig directory (default: ~/aiconfig)

EOF
        exit 1
    fi

    case "$command" in
        acquire)
            if [ -z "${2:-}" ]; then
                log_error "Usage: $0 acquire <target-file>"
                exit 1
            fi
            acquire_lock "$2"
            ;;
        release)
            if [ -z "${2:-}" ]; then
                log_error "Usage: $0 release <lock-fd>"
                exit 1
            fi
            release_lock "$2"
            ;;
        with)
            if [ -z "${2:-}" ]; then
                log_error "Usage: $0 with <target-file> -- <command> [args...]"
                exit 1
            fi
            local target_file="$2"
            shift 2

            # Skip the '--' separator if present
            if [ "${1:-}" = "--" ]; then
                shift
            fi

            if [ $# -eq 0 ]; then
                log_error "No command provided"
                exit 1
            fi

            with_lock "$target_file" "$@"
            ;;
        cleanup)
            cleanup_stale_locks
            ;;
        show)
            show_locks
            ;;
        help|--help|-h)
            "$0"
            ;;
        *)
            log_error "Unknown command: $command"
            "$0"
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
