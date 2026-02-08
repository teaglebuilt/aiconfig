#!/bin/bash
# Memory File Merge Utility
# Handles conflict resolution for memory files with different strategies
#
# Usage:
#   ./merge-memory.sh sessions /path/to/sessions.json --theirs /path/to/theirs.json
#   ./merge-memory.sh decisions /path/to/decisions.json --theirs /path/to/theirs.json
#   ./merge-memory.sh context /path/to/context.json --theirs /path/to/theirs.json
#
# Strategies:
#   sessions:  Append (both clients' sessions are valid, combine them)
#   decisions: Manual (flag conflicts for human review)
#   context:   Smart merge (auto-merge arrays, flag scalar conflicts)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_info() { echo -e "${YELLOW}[INFO]${NC} $1" >&2; }
log_conflict() { echo -e "${BLUE}[CONFLICT]${NC} $1" >&2; }

# Merge sessions files (append strategy)
merge_sessions() {
    local ours="$1"
    local theirs="$2"

    if [ ! -f "$ours" ]; then
        cat "$theirs"
        return 0
    fi

    if [ ! -f "$theirs" ]; then
        cat "$ours"
        return 0
    fi

    # Combine sessions arrays, deduplicate by id, sort by date descending
    jq -s '
        .[0] as $ours |
        .[1] as $theirs |

        # Merge version vectors (take max of each)
        (($ours._version // {}) + ($theirs._version // {})) |
        . as $merged_version |

        # Combine sessions, deduplicate by id
        (($ours.sessions // []) + ($theirs.sessions // [])) |
        group_by(.id) |
        map(.[0]) |
        sort_by(.date) |
        reverse |
        . as $merged_sessions |

        {
          "$schema": $ours["$schema"],
          "_version": $merged_version,
          "project": $ours.project,
          "sessions": $merged_sessions
        }
    ' "$ours" "$theirs"

    log_success "Merged sessions (append strategy)" >&2
}

# Merge decisions files (manual strategy)
merge_decisions() {
    local ours="$1"
    local theirs="$2"

    if [ ! -f "$ours" ]; then
        cat "$theirs"
        return 0
    fi

    if [ ! -f "$theirs" ]; then
        cat "$ours"
        return 0
    fi

    local result
    result=$(jq -s '
        .[0] as $ours |
        .[1] as $theirs |

        # Merge version vectors
        (($ours._version // {}) + ($theirs._version // {})) as $merged_version |

        # Combine decisions, mark conflicts
        [($ours.decisions // [])[] | . + {_source: "ours"}] as $ours_d |
        [($theirs.decisions // [])[] | . + {_source: "theirs"}] as $theirs_d |

        ($ours_d + $theirs_d) |
        group_by(.id) |
        map(
          if length == 1 then
            .[0] | del(._source)
          elif .[0] | del(._source) == (.[1] | del(._source)) then
            .[0] | del(._source)
          else
            .[0] | del(._source) | . + {
              _conflict: true,
              _their_version: (.[1] | del(._source)),
              _note: "Manual review required"
            }
          end
        ) |
        sort_by(.id) |
        . as $merged |

        {
          "$schema": $ours["$schema"],
          "_version": $merged_version,
          "project": $ours.project,
          "decisions": $merged
        }
    ' "$ours" "$theirs")

    local conflicts
    conflicts=$(echo "$result" | jq '[.decisions[] | select(._conflict == true)] | length')

    if [ "$conflicts" -gt 0 ]; then
        log_conflict "$conflicts decision(s) require manual review" >&2
    fi

    echo "$result"
    log_success "Merged decisions (manual strategy)" >&2
}

# Merge context files (smart merge strategy)
merge_context() {
    local ours="$1"
    local theirs="$2"

    if [ ! -f "$ours" ]; then
        cat "$theirs"
        return 0
    fi

    if [ ! -f "$theirs" ]; then
        cat "$ours"
        return 0
    fi

    local result
    result=$(jq -s '
        .[0] as $ours |
        .[1] as $theirs |

        # Merge: arrays union, objects merge, scalars prefer ours
        def smart_merge($a; $b):
          if $a == $b then $a
          elif ($a | type) == "array" and ($b | type) == "array" then
            ($a + $b) | unique
          elif ($a | type) == "object" and ($b | type) == "object" then
            reduce ([$a, $b] | add | keys[]) as $k (
              {};
              . + {($k): smart_merge($a[$k]; $b[$k])}
            )
          elif $a == null then $b
          elif $b == null then $a
          else
            {_value: $a, _conflict: true, _their_value: $b}
          end;

        smart_merge($ours; $theirs)
    ' "$ours" "$theirs")

    local has_conflicts
    has_conflicts=$(echo "$result" | jq 'any(.. | objects | select(._conflict == true))')

    if [ "$has_conflicts" = "true" ]; then
        log_conflict "Some fields have conflicts" >&2
    fi

    echo "$result"
    log_success "Merged context (smart merge strategy)" >&2
}

# Main
FILE_TYPE="${1:-}"
OURS="${2:-}"
THEIRS=""

shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --theirs)
            THEIRS="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$OURS" ] || [ -z "$THEIRS" ]; then
    echo "Memory File Merge Utility"
    echo ""
    echo "Usage:"
    echo "  merge-memory.sh sessions <ours> --theirs <theirs>"
    echo "  merge-memory.sh decisions <ours> --theirs <theirs>"
    echo "  merge-memory.sh context <ours> --theirs <theirs>"
    echo ""
    echo "Strategies:"
    echo "  sessions:  Append - combine all sessions, deduplicate by ID"
    echo "  decisions: Manual - flag conflicting ADRs for human review"
    echo "  context:   Smart  - union arrays, flag scalar conflicts"
    exit 1
fi

case "$FILE_TYPE" in
    sessions) merge_sessions "$OURS" "$THEIRS" ;;
    decisions) merge_decisions "$OURS" "$THEIRS" ;;
    context) merge_context "$OURS" "$THEIRS" ;;
    *)
        log_error "Unknown file type: $FILE_TYPE (use: sessions, decisions, context)"
        exit 1
        ;;
esac
