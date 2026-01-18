#!/bin/bash
# test_setup.sh
# Sets up a test environment for running the safe-rm tests.
# Creates temporary directories, files, and a sample configuration.

# Create a temporary test root directory
TEST_ROOT=$(mktemp -d -t safe_rm_test_XXXX)
echo "Created test directory: $TEST_ROOT"

# Create dummy files and directories inside the test root
mkdir -p "$TEST_ROOT/protected_dir"
touch "$TEST_ROOT/protected_dir/dummy.txt"
touch "$TEST_ROOT/normal_file.txt"

# Determine the repository root (assumes tests/ is under the repo root)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
CONFIG_DIR="$REPO_ROOT/config"
mkdir -p "$CONFIG_DIR"

# Create a sample JSON configuration that protects the "protected_dir"
cat << EOF > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    "protected_paths": ["$TEST_ROOT/protected_dir"]
}
EOF

echo "Test environment setup completed."
echo "Test root directory: $TEST_ROOT"
echo "Sample config created at: $CONFIG_DIR/safe_rm.json"
