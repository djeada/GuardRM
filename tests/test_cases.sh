#!/bin/bash
# test_cases.sh
# Contains automated tests for various deletion scenarios with safe_rm.

fail_count=0
pass_count=0

# Resolve paths before changing directories
ORIGINAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$ORIGINAL_DIR/.." && pwd)"
SCRIPT_DIR="$REPO_ROOT/scripts"
CONFIG_DIR="$REPO_ROOT/config"
SAFE_RM_SCRIPT="$SCRIPT_DIR/safe_rm.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

function run_test {
    local test_description="$1"
    shift
    "$@"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}[PASS]${RESET} $test_description"
        pass_count=$((pass_count+1))
    else
        echo -e "${RED}[FAIL]${RESET} $test_description"
        fail_count=$((fail_count+1))
    fi
}

echo "============================================================"
echo "GuardRM Test Suite"
echo "============================================================"
echo ""

# Create a temporary test directory and switch to it
TEST_DIR=$(mktemp -d)
echo "Setting up test environment in $TEST_DIR"
cd "$TEST_DIR" || exit 1

# Create a dummy file for deletion
touch testfile.txt

# ============================================================================
# Test 1: Interactive Mode (simulate a user cancellation)
# ============================================================================
echo ""
echo "Test 1: Interactive mode with deletion cancellation"
# Reset config to interactive mode
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "interactive",
    "protected_paths": [],
    "enable_logging": false
}
EOF
if echo "n" | "$SAFE_RM_SCRIPT" testfile.txt 2>&1 | grep -q "cancelled"; then
    echo -e "${GREEN}[PASS]${RESET} Interactive cancellation test passed."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Interactive cancellation test did not cancel deletion as expected."
    fail_count=$((fail_count+1))
fi

# Recreate test file for further tests.
touch testfile.txt

# ============================================================================
# Test 2: Protected Mode Blocking Test
# ============================================================================
echo ""
echo "Test 2: Protected mode blocking"
# Create a configuration that protects the test directory.
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": ["$TEST_DIR"],
    "enable_logging": false
}
EOF
# Attempt deletion in protected mode. This should be blocked.
if "$SAFE_RM_SCRIPT" testfile.txt 2>&1 | grep -q "ERROR:"; then
    echo -e "${GREEN}[PASS]${RESET} Protected mode blocking test passed."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Protected mode blocking test failed."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 3: Protected Mode Allowed Deletion Outside Protected Path
# ============================================================================
echo ""
echo "Test 3: Protected mode allows deletion of non-protected file"
# Create a temporary file outside the protected test directory.
TMP_OUTSIDE=$(mktemp)
if "$SAFE_RM_SCRIPT" "$TMP_OUTSIDE" 2>&1; then
    echo -e "${GREEN}[PASS]${RESET} Protected mode allowed deletion of a non-protected file."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Protected mode did not allow deletion of a non-protected file."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 4: Dry-run mode
# ============================================================================
echo ""
echo "Test 4: Dry-run mode"
touch testfile_dryrun.txt
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": [],
    "enable_logging": false
}
EOF
OUTPUT=$("$SAFE_RM_SCRIPT" --dry-run testfile_dryrun.txt 2>&1)
if echo "$OUTPUT" | grep -q "DRY-RUN" && [ -f testfile_dryrun.txt ]; then
    echo -e "${GREEN}[PASS]${RESET} Dry-run mode works correctly (file not deleted)."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Dry-run mode failed."
    fail_count=$((fail_count+1))
fi
rm -f testfile_dryrun.txt

# ============================================================================
# Test 5: Help option
# ============================================================================
echo ""
echo "Test 5: Help option"
if "$SAFE_RM_SCRIPT" --help 2>&1 | grep -q "USAGE"; then
    echo -e "${GREEN}[PASS]${RESET} Help option works correctly."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Help option failed."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 6: Force-yes option in interactive mode
# ============================================================================
echo ""
echo "Test 6: Force-yes option bypasses prompt"
touch testfile_forceyes.txt
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "interactive",
    "protected_paths": [],
    "enable_logging": false
}
EOF
"$SAFE_RM_SCRIPT" --force-yes testfile_forceyes.txt 2>&1
if [ ! -f testfile_forceyes.txt ]; then
    echo -e "${GREEN}[PASS]${RESET} Force-yes option bypassed prompt and deleted file."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Force-yes option failed to delete file."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 7: Non-existent file handling
# ============================================================================
echo ""
echo "Test 7: Non-existent file handling"
OUTPUT=$("$SAFE_RM_SCRIPT" nonexistent_file_12345.txt 2>&1)
if echo "$OUTPUT" | grep -q "No such file"; then
    echo -e "${GREEN}[PASS]${RESET} Non-existent file handled correctly."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Non-existent file not handled correctly."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 8: Pattern-based protection
# ============================================================================
echo ""
echo "Test 8: Pattern-based protection"
touch "test.production.db"
cat << 'EOFPATTERN' > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": [],
    "protected_patterns": [".*\\.production\\..*"],
    "enable_logging": false
}
EOFPATTERN
OUTPUT=$("$SAFE_RM_SCRIPT" "test.production.db" 2>&1)
if echo "$OUTPUT" | grep -q "protected pattern" && [ -f "test.production.db" ]; then
    echo -e "${GREEN}[PASS]${RESET} Pattern-based protection works correctly."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Pattern-based protection failed."
    fail_count=$((fail_count+1))
fi
rm -f "test.production.db"

# ============================================================================
# Test 9: Multiple targets handling
# ============================================================================
echo ""
echo "Test 9: Multiple targets handling"
touch multi1.txt multi2.txt multi3.txt
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": [],
    "enable_logging": false
}
EOF
"$SAFE_RM_SCRIPT" multi1.txt multi2.txt multi3.txt 2>&1
if [ ! -f multi1.txt ] && [ ! -f multi2.txt ] && [ ! -f multi3.txt ]; then
    echo -e "${GREEN}[PASS]${RESET} Multiple targets handled correctly."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Multiple targets handling failed."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Test 10: Logging functionality
# ============================================================================
echo ""
echo "Test 10: Logging functionality"
touch testfile_logging.txt
LOG_DIR="$REPO_ROOT/logs"
LOG_FILE="$LOG_DIR/safe_rm.log"
rm -f "$LOG_FILE"
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": [],
    "enable_logging": true
}
EOF
"$SAFE_RM_SCRIPT" testfile_logging.txt 2>&1
if [ -f "$LOG_FILE" ] && grep -q "DELETE" "$LOG_FILE"; then
    echo -e "${GREEN}[PASS]${RESET} Logging functionality works correctly."
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Logging functionality failed."
    fail_count=$((fail_count+1))
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "============================================================"
echo "Test Summary: $pass_count passed, $fail_count failed."
echo "============================================================"

# Restore default config
cat << 'EOFCONFIG' > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "interactive",
    "protected_paths": [
        "/var/www/prod",
        "/data/critical",
        "/etc",
        "/boot",
        "/usr"
    ],
    "protected_patterns": [
        ".*\\.production\\..*",
        ".*\\.prod\\.db$"
    ],
    "enable_logging": true,
    "prompt_timeout": 0
}
EOFCONFIG

# Cleanup
cd /
rm -rf "$TEST_DIR"

# Exit with failure if any tests failed
if [ $fail_count -gt 0 ]; then
    exit 1
fi
exit 0
