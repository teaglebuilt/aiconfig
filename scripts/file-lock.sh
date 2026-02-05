#!/bin/bash
# File Locking Utility
# Provides advisory file locking to prevent concurrent writes from multiple clients
#
# Usage:
#   ./file-lock.sh acquire /path/to/file.json [--timeout 30] [--client claude-code]
#   ./file-lock.sh release /path/to/file.json
#   ./file-lock.sh status /path/to/file.json
#   ./file-lock.sh cleanup              # Remove stale locks
#
# Lock files are created as {filename}.lock with metadata about the holder

set -e

# Configuration
LOCK_TIMEOUT_DEFAULT=300  # 5 minutes default lock expiration
ACQUIRE_TIMEOUT_DEFAULT=30  # 30 seconds default wait for lock

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1" >&2; }

# Get lock file path for a target file
get_lock_file() {
    echo "${1}.lock"
}

# Check if a lock is stale (older than LOCK_TIMEOUT_DEFAULT seconds)
is_lock_stale() {
    local lock_file="$1"
    if [ ! -f "$lock_file" ]; then
        return 0  # No lock = consider it stale (acquirable)
    fi

    local lock_time
    lock_time=$(jq -r '.acquired_at // empty' "$lock_file" 2>/dev/null)
    if [ -z "$lock_time" ]; then
        return 0  # Invalid lock file
    fi

    local lock_epoch
    lock_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$lock_time" "+%s" 2>/dev/null || date -d "$lock_time" "+%s" 2>/dev/null)
    if [ -z "$lock_epoch" ]; then
        return 0  # Can't parse time, assume stale
    fi

    local now_epoch
    now_epoch=$(date "+%s")
    local age=$((now_epoch - lock_epoch))

    [ "$age" -gt "$LOCK_TIMEOUT_DEFAULT" ]
}

# Acquire a lock
acquire_lock() {
    local target_file="$1"
    local timeout="${2:-$ACQUIRE_TIMEOUT_DEFAULT}"
    local client="${3:-unknown}"

    local lock_file
    lock_file=$(get_lock_file "$target_file")

    local start_time
    start_time=$(date "+%s")

    while true; do
        # Check if lock exists and is not stale
        if [ -f "$lock_file" ] && ! is_lock_stale "$lock_file"; then
            local holder
            holder=$(jq -r '.client // "unknown"' "$lock_file" 2>/dev/null)

            # Check timeout
            local now
            now=$(date "+%s")
            local elapsed=$((now - start_time))

            if [ "$elapsed" -ge "$timeout" ]; then
                log_error "Timeout waiting for lock on $target_file (held by $holder)"
                return 1
            fi

            log_info "Waiting for lock (held by $holder)... ${elapsed}s/${timeout}s"
            sleep 1
            continue
        fi

        # Try to acquire lock atomically
        local lock_content
        lock_content=$(cat <<EOF
{
  "target": "$target_file",
  "client": "$client",
  "acquired_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "pid": $$,
  "hostname": "$(hostname)"
}
EOF
)

        # Use atomic write for the lock file itself
        local temp_lock
        temp_lock=$(mktemp "${lock_file}.XXXXXX")
        echo "$lock_content" > "$temp_lock"

        # Try to create lock file (will fail if it exists)
        if ln "$temp_lock" "$lock_file" 2>/dev/null; then
            rm -f "$temp_lock"
            log_success "Acquired lock: $lock_file"
            echo "$lock_file"
            return 0
        fi

        rm -f "$temp_lock"

        # Lock was created by someone else, check if it's stale
        if is_lock_stale "$lock_file"; then
            log_info "Removing stale lock"
            rm -f "$lock_file"
            continue
        fi

        # Check timeout
        local now
        now=$(date "+%s")
        local elapsed=$((now - start_time))

        if [ "$elapsed" -ge "$timeout" ]; then
            log_error "Timeout waiting for lock on $target_file"
            return 1
        fi

        sleep 1
    done
}

# Release a lock
release_lock() {
    local target_file="$1"
    local lock_file
    lock_file=$(get_lock_file "$target_file")

    if [ ! -f "$lock_file" ]; then
        log_info "No lock to release: $lock_file"
        return 0
    fi

    rm -f "$lock_file"
    log_success "Released lock: $lock_file"
    return 0
}

# Check lock status
check_status() {
    local target_file="$1"
    local lock_file
    lock_file=$(get_lock_file "$target_file")

    if [ ! -f "$lock_file" ]; then
        echo "unlocked"
        return 0
    fi

    if is_lock_stale "$lock_file"; then
        echo "stale"
        return 0
    fi

    local holder
    holder=$(jq -r '.client // "unknown"' "$lock_file" 2>/dev/null)
    local acquired
    acquired=$(jq -r '.acquired_at // "unknown"' "$lock_file" 2>/dev/null)

    echo "locked by $holder since $acquired"
    return 1
}

# Cleanup stale locks in a directory
cleanup_locks() {
    local dir="${1:-$HOME/aiconfig/memory}"
    local count=0

    while IFS= read -r -d '' lock_file; do
        if is_lock_stale "$lock_file"; then
            rm -f "$lock_file"
            log_info "Removed stale lock: $lock_file"
            ((count++))
        fi
    done < <(find "$dir" -name "*.lock" -print0 2>/dev/null)

    log_success "Cleaned up $count stale lock(s)"
}

# Main
ACTION="${1:-}"
TARGET="${2:-}"

case "$ACTION" in
    acquire)
        if [ -z "$TARGET" ]; then
            log_error "Usage: file-lock.sh acquire <file> [--timeout N] [--client NAME]"
            exit 1
        fi

        # Parse additional arguments
        shift 2
        TIMEOUT="$ACQUIRE_TIMEOUT_DEFAULT"
        CLIENT="unknown"

        while [[ $# -gt 0 ]]; do
            case $1 in
                --timeout)
                    TIMEOUT="$2"
                    shift 2
                    ;;
                --client)
                    CLIENT="$2"
                    shift 2
                    ;;
                *)
                    log_error "Unknown option: $1"
                    exit 1
                    ;;
            esac
        done

        acquire_lock "$TARGET" "$TIMEOUT" "$CLIENT"
        ;;

    release)
        if [ -z "$TARGET" ]; then
            log_error "Usage: file-lock.sh release <file>"
            exit 1
        fi
        release_lock "$TARGET"
        ;;

    status)
        if [ -z "$TARGET" ]; then
            log_error "Usage: file-lock.sh status <file>"
            exit 1
        fi
        check_status "$TARGET"
        ;;

    cleanup)
        cleanup_locks "$TARGET"
        ;;

    *)
        echo "File Locking Utility"
        echo ""
        echo "Usage:"
        echo "  file-lock.sh acquire <file> [--timeout N] [--client NAME]"
        echo "  file-lock.sh release <file>"
        echo "  file-lock.sh status <file>"
        echo "  file-lock.sh cleanup [directory]"
        echo ""
        echo "Options:"
        echo "  --timeout N    Wait up to N seconds for lock (default: 30)"
        echo "  --client NAME  Identifier for lock holder (default: unknown)"
        exit 1
        ;;
esac
