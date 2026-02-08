#!/bin/bash
# Version Vector Utility
# Tracks per-client versions for conflict detection
#
# Usage:
#   ./version-vector.sh read /path/to/file.json
#   ./version-vector.sh increment /path/to/file.json --client claude-code
#   ./version-vector.sh check /path/to/file.json --client claude-code --expected '{"claude-code":1}'
#
# Version vectors are stored in the JSON file under "_version" key:
# {
#   "_version": {
#     "claude-code": 3,
#     "cursor": 2
#   },
#   "data": "..."
# }

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1" >&2; }

# Read version vector from file
read_version() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "{}"
        return 0
    fi

    local version
    version=$(jq -r '._version // {}' "$file" 2>/dev/null)

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "{}"
    else
        echo "$version"
    fi
}

# Increment version for a client
increment_version() {
    local file="$1"
    local client="$2"

    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi

    # Read current content
    local content
    content=$(cat "$file")

    # Get current version for this client (default 0)
    local current_version
    current_version=$(echo "$content" | jq -r "._version.\"$client\" // 0" 2>/dev/null)

    # Increment
    local new_version=$((current_version + 1))

    # Update the file with new version
    local updated
    updated=$(echo "$content" | jq "._version.\"$client\" = $new_version")

    # If _version didn't exist, create it
    if [ "$(echo "$updated" | jq 'has("_version")')" = "false" ]; then
        updated=$(echo "$content" | jq ". + {\"_version\": {\"$client\": $new_version}}")
    fi

    echo "$updated"
}

# Check if local version matches expected (for conflict detection)
check_version() {
    local file="$1"
    local client="$2"
    local expected="$3"

    if [ ! -f "$file" ]; then
        # New file, no conflict
        echo "ok:new"
        return 0
    fi

    local current_version
    current_version=$(read_version "$file")

    # If no expected version provided, just return current
    if [ -z "$expected" ]; then
        echo "current:$current_version"
        return 0
    fi

    # Compare versions
    # A conflict exists if any client's version in the file is greater than expected
    local conflict=false
    local conflict_clients=""

    # Get all clients from current version
    local clients
    clients=$(echo "$current_version" | jq -r 'keys[]' 2>/dev/null)

    for c in $clients; do
        local current_v
        current_v=$(echo "$current_version" | jq -r ".\"$c\" // 0")
        local expected_v
        expected_v=$(echo "$expected" | jq -r ".\"$c\" // 0")

        if [ "$current_v" -gt "$expected_v" ]; then
            conflict=true
            conflict_clients="$conflict_clients $c"
        fi
    done

    if [ "$conflict" = true ]; then
        echo "conflict:$conflict_clients"
        return 1
    else
        echo "ok:in_sync"
        return 0
    fi
}

# Initialize version vector in a file
init_version() {
    local file="$1"
    local client="$2"

    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi

    local content
    content=$(cat "$file")

    # Check if already has version
    if [ "$(echo "$content" | jq 'has("_version")')" = "true" ]; then
        log_info "Version vector already exists"
        echo "$content"
        return 0
    fi

    # Add initial version
    local updated
    updated=$(echo "$content" | jq ". + {\"_version\": {\"$client\": 1}}")

    echo "$updated"
}

# Get summary of version state
summary() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "File not found"
        return 1
    fi

    local version
    version=$(read_version "$file")

    if [ "$version" = "{}" ]; then
        echo "No version tracking"
        return 0
    fi

    echo "Version vector:"
    echo "$version" | jq -r 'to_entries[] | "  \(.key): v\(.value)"'
}

# Main
ACTION="${1:-}"
TARGET="${2:-}"

case "$ACTION" in
    read)
        if [ -z "$TARGET" ]; then
            log_error "Usage: version-vector.sh read <file>"
            exit 1
        fi
        read_version "$TARGET"
        ;;

    increment)
        if [ -z "$TARGET" ]; then
            log_error "Usage: version-vector.sh increment <file> --client NAME"
            exit 1
        fi
        shift 2
        CLIENT=""
        while [[ $# -gt 0 ]]; do
            case $1 in
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
        if [ -z "$CLIENT" ]; then
            log_error "Client name required: --client NAME"
            exit 1
        fi
        increment_version "$TARGET" "$CLIENT"
        ;;

    check)
        if [ -z "$TARGET" ]; then
            log_error "Usage: version-vector.sh check <file> --client NAME [--expected JSON]"
            exit 1
        fi
        shift 2
        CLIENT=""
        EXPECTED=""
        while [[ $# -gt 0 ]]; do
            case $1 in
                --client)
                    CLIENT="$2"
                    shift 2
                    ;;
                --expected)
                    EXPECTED="$2"
                    shift 2
                    ;;
                *)
                    log_error "Unknown option: $1"
                    exit 1
                    ;;
            esac
        done
        if [ -z "$CLIENT" ]; then
            log_error "Client name required: --client NAME"
            exit 1
        fi
        check_version "$TARGET" "$CLIENT" "$EXPECTED"
        ;;

    init)
        if [ -z "$TARGET" ]; then
            log_error "Usage: version-vector.sh init <file> --client NAME"
            exit 1
        fi
        shift 2
        CLIENT=""
        while [[ $# -gt 0 ]]; do
            case $1 in
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
        if [ -z "$CLIENT" ]; then
            log_error "Client name required: --client NAME"
            exit 1
        fi
        init_version "$TARGET" "$CLIENT"
        ;;

    summary)
        if [ -z "$TARGET" ]; then
            log_error "Usage: version-vector.sh summary <file>"
            exit 1
        fi
        summary "$TARGET"
        ;;

    *)
        echo "Version Vector Utility"
        echo ""
        echo "Usage:"
        echo "  version-vector.sh read <file>                    Read version vector"
        echo "  version-vector.sh increment <file> --client NAME Increment client version"
        echo "  version-vector.sh check <file> --client NAME [--expected JSON]"
        echo "                                                   Check for conflicts"
        echo "  version-vector.sh init <file> --client NAME      Initialize version tracking"
        echo "  version-vector.sh summary <file>                 Show version summary"
        echo ""
        echo "Version vectors enable conflict detection when multiple clients"
        echo "(Claude Code, Cursor) modify the same memory files."
        exit 1
        ;;
esac
