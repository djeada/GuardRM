#!/bin/bash
# safe_rm.sh
# Intercepts calls to rm and rmdir, and either warns the user interactively or
# blocks deletion for protected paths as defined in the JSON configuration.
#
# Features:
# - Color-coded output for better visibility
# - Logging of deletion attempts
# - Dry-run mode for testing
# - Pattern-based protection with wildcards
# - Timeout option for interactive prompts

# ============================================================================
# Color Definitions
# ============================================================================
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ============================================================================
# Configuration
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/safe_rm.json"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/safe_rm.log"

# Defaults
MODE="interactive"
ENABLE_LOGGING=false
PROMPT_TIMEOUT=0
DRY_RUN=false
HOSTNAME="$(hostname)"
USERNAME="$(whoami)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# ============================================================================
# Functions
# ============================================================================

log_action() {
    local action="$1"
    local target="$2"
    local result="$3"
    
    if [[ "$ENABLE_LOGGING" == "true" ]]; then
        mkdir -p "$LOG_DIR"
        echo "[$TIMESTAMP] [$USERNAME@$HOSTNAME] $action: $target -> $result" >> "$LOG_FILE"
    fi
}

print_banner() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${MAGENTA}GuardRM${RESET} - Safe Deletion Protection                          ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${RESET}"
}

print_warning() {
    local target="$1"
    echo -e ""
    echo -e "${YELLOW}┌────────────────────────────────────────────────────────────────┐${RESET}"
    echo -e "${YELLOW}│${RESET}  ${BOLD}⚠  DELETION WARNING${RESET}                                          ${YELLOW}│${RESET}"
    echo -e "${YELLOW}├────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "${YELLOW}│${RESET}  ${BLUE}Host:${RESET}   ${BOLD}$HOSTNAME${RESET}"
    echo -e "${YELLOW}│${RESET}  ${BLUE}User:${RESET}   ${BOLD}$USERNAME${RESET}"
    echo -e "${YELLOW}│${RESET}  ${BLUE}Time:${RESET}   $TIMESTAMP"
    echo -e "${YELLOW}│${RESET}  ${RED}Target:${RESET} ${BOLD}$target${RESET}"
    echo -e "${YELLOW}└────────────────────────────────────────────────────────────────┘${RESET}"
}

print_error() {
    local message="$1"
    echo -e "${RED}${BOLD}ERROR:${RESET} ${RED}$message${RESET}" >&2
}

print_success() {
    local message="$1"
    echo -e "${GREEN}${BOLD}✓${RESET} ${GREEN}$message${RESET}"
}

print_info() {
    local message="$1"
    echo -e "${BLUE}${BOLD}ℹ${RESET} ${BLUE}$message${RESET}"
}

check_protected_path() {
    local abs_path="$1"
    
    for protected in $PROTECTED_PATHS; do
        # Support wildcard patterns
        if [[ "$protected" == *"*"* ]]; then
            # Use pattern matching for wildcards
            if [[ "$abs_path" == $protected ]]; then
                return 0
            fi
        else
            # Exact prefix matching for regular paths
            if [[ "$abs_path" == "$protected"* ]]; then
                return 0
            fi
        fi
    done
    return 1
}

check_protected_pattern() {
    local abs_path="$1"
    
    for pattern in $PROTECTED_PATTERNS; do
        if [[ "$abs_path" =~ $pattern ]]; then
            return 0
        fi
    done
    return 1
}

show_help() {
    print_banner
    echo ""
    echo -e "${BOLD}USAGE:${RESET}"
    echo "  safe_rm.sh [OPTIONS] FILE..."
    echo ""
    echo -e "${BOLD}OPTIONS:${RESET}"
    echo "  --dry-run     Show what would be deleted without actually deleting"
    echo "  --force-yes   Skip interactive prompts (use with caution)"
    echo "  --help        Show this help message"
    echo ""
    echo -e "${BOLD}MODES:${RESET}"
    echo "  interactive   Prompts user before each deletion (default)"
    echo "  protected     Blocks deletion of protected paths, allows others"
    echo ""
    echo -e "${BOLD}CONFIGURATION:${RESET}"
    echo "  Config file: $CONFIG_FILE"
    echo ""
}

# ============================================================================
# Parse Configuration File
# ============================================================================
if [ -f "$CONFIG_FILE" ]; then
    # Read mode
    MODE_CONF=$(jq -r '.mode // "interactive"' "$CONFIG_FILE" 2>/dev/null)
    if [[ "$MODE_CONF" == "protected" || "$MODE_CONF" == "interactive" ]]; then
        MODE="$MODE_CONF"
    fi
    
    # Read protected paths as newline-separated values
    PROTECTED_PATHS=$(jq -r '.protected_paths[]?' "$CONFIG_FILE" 2>/dev/null)
    
    # Read protected patterns (regex patterns)
    PROTECTED_PATTERNS=$(jq -r '.protected_patterns[]?' "$CONFIG_FILE" 2>/dev/null)
    
    # Read logging configuration
    ENABLE_LOGGING=$(jq -r '.enable_logging // false' "$CONFIG_FILE" 2>/dev/null)
    
    # Read prompt timeout (seconds, 0 = no timeout)
    PROMPT_TIMEOUT=$(jq -r '.prompt_timeout // 0' "$CONFIG_FILE" 2>/dev/null)
fi

# ============================================================================
# Parse Command Line Arguments
# ============================================================================
FORCE_YES=false
TARGETS=()
RM_OPTIONS=()

for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --force-yes)
            FORCE_YES=true
            ;;
        --help)
            show_help
            exit 0
            ;;
        -*)
            RM_OPTIONS+=("$arg")
            ;;
        *)
            TARGETS+=("$arg")
            ;;
    esac
done

# ============================================================================
# Main Logic
# ============================================================================

# If no targets were given, delegate directly to the system rm.
if [ ${#TARGETS[@]} -eq 0 ]; then
    if [ ${#RM_OPTIONS[@]} -eq 0 ]; then
        command rm --help 2>/dev/null || echo "Usage: rm [OPTION]... FILE..."
        exit 0
    fi
    command rm "${RM_OPTIONS[@]}"
    exit $?
fi

# Display banner for interactive mode
if [[ "$MODE" == "interactive" && "$FORCE_YES" == "false" ]]; then
    print_banner
fi

# Track blocked and cancelled targets
BLOCKED_TARGETS=()
CANCELLED_TARGETS=()
APPROVED_TARGETS=()

# For each target, compute its absolute path and perform checks.
for target in "${TARGETS[@]}"; do
    ABS_PATH=$(realpath "$target" 2>/dev/null)
    if [ -z "$ABS_PATH" ]; then
        ABS_PATH="$target"
    fi
    
    # Check if path exists
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        print_error "Cannot remove '$target': No such file or directory"
        log_action "DELETE_ATTEMPT" "$ABS_PATH" "NOT_FOUND"
        continue
    fi
    
    # Protected mode: check against protected paths and patterns
    if [[ "$MODE" == "protected" ]]; then
        if check_protected_path "$ABS_PATH"; then
            print_error "Deletion blocked. '$ABS_PATH' is a protected path."
            log_action "DELETE_ATTEMPT" "$ABS_PATH" "BLOCKED_PROTECTED_PATH"
            BLOCKED_TARGETS+=("$target")
            continue
        fi
        if check_protected_pattern "$ABS_PATH"; then
            print_error "Deletion blocked. '$ABS_PATH' matches a protected pattern."
            log_action "DELETE_ATTEMPT" "$ABS_PATH" "BLOCKED_PROTECTED_PATTERN"
            BLOCKED_TARGETS+=("$target")
            continue
        fi
        # In protected mode, non-protected paths are allowed
        APPROVED_TARGETS+=("$target")
        
    # Interactive mode: prompt for confirmation
    elif [[ "$MODE" == "interactive" ]]; then
        if [[ "$FORCE_YES" == "true" || "$DRY_RUN" == "true" ]]; then
            APPROVED_TARGETS+=("$target")
            if [[ "$DRY_RUN" != "true" ]]; then
                log_action "DELETE_ATTEMPT" "$ABS_PATH" "FORCE_APPROVED"
            fi
        else
            print_warning "$ABS_PATH"
            
            # Show file type and size info
            if [[ -d "$target" ]]; then
                file_count=$(find "$target" -type f 2>/dev/null | wc -l)
                echo -e "  ${CYAN}Type:${RESET}   Directory (${file_count} files)"
            else
                file_size=$(du -h "$target" 2>/dev/null | cut -f1)
                echo -e "  ${CYAN}Type:${RESET}   File (${file_size})"
            fi
            echo ""
            
            # Interactive prompt with optional timeout
            if [[ "$PROMPT_TIMEOUT" -gt 0 ]]; then
                echo -e "${YELLOW}Proceed with deletion? (y/N) [${PROMPT_TIMEOUT}s timeout]:${RESET} "
                read -t "$PROMPT_TIMEOUT" -r response
                if [[ $? -gt 128 ]]; then
                    echo ""
                    print_info "Timeout reached. Deletion cancelled for $ABS_PATH"
                    log_action "DELETE_ATTEMPT" "$ABS_PATH" "TIMEOUT_CANCELLED"
                    CANCELLED_TARGETS+=("$target")
                    continue
                fi
            else
                read -p "Proceed with deletion? (y/N): " -r response
            fi
            
            if [[ "$response" =~ ^[Yy]$ ]]; then
                APPROVED_TARGETS+=("$target")
                log_action "DELETE_ATTEMPT" "$ABS_PATH" "USER_APPROVED"
            else
                print_info "Deletion cancelled for $ABS_PATH"
                log_action "DELETE_ATTEMPT" "$ABS_PATH" "USER_CANCELLED"
                CANCELLED_TARGETS+=("$target")
            fi
        fi
    fi
done

# ============================================================================
# Execute Deletion
# ============================================================================

if [ ${#APPROVED_TARGETS[@]} -eq 0 ]; then
    if [ ${#BLOCKED_TARGETS[@]} -gt 0 ] || [ ${#CANCELLED_TARGETS[@]} -gt 0 ]; then
        exit 1
    fi
    exit 0
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo ""
    print_info "DRY-RUN MODE - No files will be deleted"
    echo -e "${BOLD}Would delete:${RESET}"
    for target in "${APPROVED_TARGETS[@]}"; do
        echo -e "  ${RED}→${RESET} $target"
    done
    exit 0
fi

# Proceed with deletion of approved targets
command rm "${RM_OPTIONS[@]}" "${APPROVED_TARGETS[@]}"
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
    for target in "${APPROVED_TARGETS[@]}"; do
        log_action "DELETE" "$target" "SUCCESS"
    done
    if [[ "$MODE" == "interactive" && "$FORCE_YES" == "false" ]]; then
        print_success "Deletion completed successfully"
    fi
else
    for target in "${APPROVED_TARGETS[@]}"; do
        log_action "DELETE" "$target" "FAILED"
    done
    print_error "Deletion failed with exit code $exit_code"
fi

exit $exit_code
