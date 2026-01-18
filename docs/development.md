# Development Guidelines

This document provides guidelines for contributing to and extending GuardRM. Whether you are fixing bugs, adding new features, or improving documentation, this guide will help maintain consistency and quality across the project.

## Repository Structure

```
GuardRM/
├── config/             # Configuration files
│   └── safe_rm.json    # Default configuration
├── docs/               # Documentation
│   ├── development.md  # This file
│   ├── installation.md # Setup instructions
│   └── usage.md        # User guide
├── logs/               # Log files (gitignored except .gitkeep)
│   └── .gitkeep        # Keeps directory in git
├── scripts/            # Main scripts
│   ├── alias_setup.sh  # Setup wizard
│   └── safe_rm.sh      # Core protection script
└── tests/              # Automated tests
    ├── test_cases.sh   # Test suite
    └── test_setup.sh   # Test environment setup
```

## Coding Standards

### Bash Style

- Use `#!/bin/bash` as the interpreter
- Use clear variable names with descriptive comments
- Use uppercase for global variables and constants
- Use lowercase for local variables
- Ensure that scripts are executable (`chmod +x`)
- Use `[[ ]]` for conditionals (more robust than `[ ]`)
- Quote variables to prevent word splitting: `"$variable"`

### Code Organization

- Group related functionality into functions
- Use clear section separators (comment blocks)
- Keep functions focused and single-purpose
- Add error handling for edge cases

### Color Output

When adding colored output:
```bash
# Check if output is a terminal
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    RESET='\033[0m'
else
    RED=''
    RESET=''
fi
```

### Documentation

- Update the corresponding Markdown files in `docs/` for any significant changes
- Keep the user guide and installation instructions up to date with new features
- Use clear examples with expected output

## Testing

### Running Tests

```bash
# Run the full test suite
cd tests
./test_cases.sh
```

### Test Coverage

Current test coverage includes:
1. Interactive mode cancellation
2. Protected mode blocking
3. Non-protected file deletion
4. Dry-run mode
5. Help option
6. Force-yes option
7. Non-existent file handling
8. Pattern-based protection
9. Multiple targets handling
10. Logging functionality

### Adding New Tests

When adding tests, follow this pattern:
```bash
# ============================================================================
# Test N: Description
# ============================================================================
echo ""
echo "Test N: Description"
# Setup
touch testfile.txt
# Configure
cat << 'EOF' > "$CONFIG_DIR/safe_rm.json"
{
    "mode": "protected",
    ...
}
EOF
# Execute and verify
OUTPUT=$("$SAFE_RM_SCRIPT" testfile.txt 2>&1)
if echo "$OUTPUT" | grep -q "expected_text"; then
    echo -e "${GREEN}[PASS]${RESET} Test description"
    pass_count=$((pass_count+1))
else
    echo -e "${RED}[FAIL]${RESET} Test description"
    fail_count=$((fail_count+1))
fi
# Cleanup
rm -f testfile.txt
```

**Important:** Use `'EOF'` (quoted) for heredocs containing regex patterns or special characters to prevent shell expansion.

## Pull Requests and Contributions

### Branching

- Follow the Git branching model used in the repository
- Work on feature branches and open pull requests against the main branch
- Use descriptive branch names: `feature/add-logging`, `fix/pattern-matching`

### Commit Messages

- Write clear and descriptive commit messages
- Reference issues where applicable: `Fix #123: Add pattern-based protection`
- Use imperative mood: "Add feature" not "Added feature"

### Code Reviews

- Participate actively in code reviews
- Ensure that your code meets the coding standards
- Verify all tests pass before submitting

### Feature Requests

- If proposing a major change, open an issue first to discuss the design
- Include use cases and expected behavior in feature requests

## Architecture

### Core Script (safe_rm.sh)

The main script follows this flow:

1. **Initialization**
   - Define color codes
   - Set configuration defaults
   - Parse configuration file

2. **Argument Parsing**
   - Separate rm options from targets
   - Handle special flags (--dry-run, --force-yes, --help)

3. **Target Processing**
   - For each target:
     - Resolve absolute path
     - Check existence
     - Apply mode-specific logic (protected/interactive)
     - Categorize as blocked, cancelled, or approved

4. **Execution**
   - Handle dry-run mode
   - Execute deletion for approved targets
   - Log results

### Configuration Schema

```json
{
    "mode": "interactive|protected",
    "protected_paths": ["string array of absolute paths"],
    "protected_patterns": ["string array of regex patterns"],
    "enable_logging": true|false,
    "prompt_timeout": 0 (number, seconds)
}
```

## Future Enhancements

Consider the following areas when extending the tool:

- **Trash/Recycle Bin:** Move files to a trash directory instead of permanent deletion
- **Undo Capability:** Allow recovery of recently deleted files
- **User Roles:** Different protection levels based on user roles
- **Time-Based Rules:** Allow/block deletions during specific hours
- **Notification Integration:** Send alerts for blocked deletion attempts
- **Web Dashboard:** Visual interface for viewing logs and managing configuration
- **CI/CD Integration:** Add automated checks and deployment pipelines
- **Backup Before Delete:** Automatically backup files before deletion

## Dependencies

- **jq:** JSON parsing (required)
- **coreutils:** Standard Unix utilities (rm, realpath, etc.)
- **bash:** Version 4.0 or higher recommended

We welcome contributions and improvements that help make GuardRM a more robust and versatile tool for managing production data safely!
