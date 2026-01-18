#!/bin/bash
# test_cases.sh
# Contains automated tests for various deletion scenarios with safe_rm.

fail_count=0
pass_count=0

function run_test {
    local test_description="$1"
    shift
    "$@"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "[PASS] $test_description"
        pass_count=$((pass_count+1))
    else
        echo "[FAIL] $test_description"
        fail_count=$((fail_count+1))
    fi
}

# Create a temporary test directory and switch to it
TEST_DIR=$(mktemp -d)
echo "Setting up test environment in $TEST_DIR"
cd "$TEST_DIR" || exit 1

# Create a dummy file for deletion
touch testfile.txt

# Test 1: Interactive Mode (simulate a user cancellation)
echo "Testing interactive mode with deletion cancellation."
# Simulate input "n" by echoing 'n' into the command. Note: This test assumes no protected mode.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
SAFE_RM_SCRIPT="$SCRIPT_DIR/safe_rm.sh"
if echo "n" | "$SAFE_RM_SCRIPT" testfile.txt 2>&1 | grep -q "Deletion cancelled"; then
    echo "[PASS] Interactive cancellation test passed."
    pass_count=$((pass_count+1))
else
    echo "[FAIL] Interactive cancellation test did not cancel deletion as expected."
    fail_count=$((fail_count+1))
fi

# Recreate test file for further tests.
touch testfile.txt

# Test 2: Protected Mode Blocking Test
echo "Testing protected mode blocking."
# Create a configuration that protects the test directory.
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../config" && pwd)"
CONFIG_FILE="$CONFIG_DIR/safe_rm.json"
cat << EOF > "$CONFIG_FILE"
{
    "mode": "protected",
    "protected_paths": ["$TEST_DIR"]
}
EOF
# Attempt deletion in protected mode. This should be blocked.
if "$SAFE_RM_SCRIPT" testfile.txt 2>&1 | grep -q "ERROR:"; then
    echo "[PASS] Protected mode blocking test passed."
    pass_count=$((pass_count+1))
else
    echo "[FAIL] Protected mode blocking test failed."
    fail_count=$((fail_count+1))
fi

# Test 3: Protected Mode Allowed Deletion Outside Protected Path
echo "Testing protected mode deletion for non-protected file."
# Create a temporary file outside the protected test directory.
TMP_OUTSIDE=$(mktemp)
if "$SAFE_RM_SCRIPT" "$TMP_OUTSIDE" 2>&1; then
    echo "[PASS] Protected mode allowed deletion of a non-protected file."
    pass_count=$((pass_count+1))
else
    echo "[FAIL] Protected mode did not allow deletion of a non-protected file."
    fail_count=$((fail_count+1))
fi

# Display summary of test results.
echo "Test Summary: $pass_count passed, $fail_count failed."

# Cleanup
rm -rf "$TEST_DIR"
