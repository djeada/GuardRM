#!/bin/bash
# safe_rm.sh
# Intercepts calls to rm and rmdir, and either warns the user interactively or
# blocks deletion for protected paths as defined in the JSON configuration.

# Locate the configuration file (assumed at ../config/safe_rm.json relative to this script)
CONFIG_FILE="$(dirname "$0")/../config/safe_rm.json"
# Default mode is "interactive"
MODE="interactive"
HOSTNAME="$(hostname)"

# If configuration exists, attempt to read mode and protected paths using jq
if [ -f "$CONFIG_FILE" ]; then
    MODE_CONF=$(jq -r '.mode' "$CONFIG_FILE" 2>/dev/null)
    if [[ "$MODE_CONF" == "protected" ]]; then
        MODE="protected"
    fi
    # Read protected paths as newline-separated values
    PROTECTED_PATHS=$(jq -r '.protected_paths[]?' "$CONFIG_FILE")
fi

# Collect non-option arguments as targets.
TARGETS=()
for arg in "$@"; do
    if [[ "$arg" != -* ]]; then
        TARGETS+=("$arg")
    fi
done

# If no targets were given, delegate directly to the system rm.
if [ ${#TARGETS[@]} -eq 0 ]; then
    command rm "$@"
    exit $?
fi

# For each target, compute its absolute path and perform checks.
for target in "${TARGETS[@]}"; do
    ABS_PATH=$(realpath "$target" 2>/dev/null)
    if [ -z "$ABS_PATH" ]; then
        ABS_PATH="$target"
    fi
    echo "YOU ARE ON HOST: $HOSTNAME"
    echo "YOU WANT TO DELETE: $ABS_PATH"
    
    if [ "$MODE" = "interactive" ]; then
        read -p "Proceed with deletion? (y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Deletion cancelled for $ABS_PATH"
            exit 1
        fi
    elif [ "$MODE" = "protected" ]; then
        # Check if the absolute path starts with any protected path
        for protected in $PROTECTED_PATHS; do
            if [[ "$ABS_PATH" == "$protected"* ]]; then
                echo "ERROR: Deletion blocked. '$ABS_PATH' is a protected path."
                exit 1
            fi
        done
    fi
done

# All checks passed; proceed with deletion.
command rm "$@"
exit $?
