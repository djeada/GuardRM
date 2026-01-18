# Usage Guide

This document explains how to use the GuardRM tool to intercept and secure removal operations on your system.

## Overview

GuardRM provides a comprehensive safeguard against accidental deletion of critical files and directories. It intercepts `rm` and `rmdir` commands and provides multiple layers of protection.

## Modes of Operation

The tool operates in two main modes based on the JSON configuration in `config/safe_rm.json`:

### 1. Interactive Mode (Default)
- **Behavior:** When executing a deletion command, the tool displays a colorful, informative warning showing:
  - Current hostname
  - Current user
  - Timestamp
  - Target file/directory path
  - File type and size information
- **Prompt:** The user is prompted to confirm the deletion
- **Use Case:** Ideal for everyday use where a confirmation helps prevent accidental deletions

### 2. Protected Mode
- **Behavior:** The tool blocks deletion of files or directories that match any of the protected paths or patterns defined in the configuration
- **Error Message:** An error message is displayed if a deletion is attempted on a protected path
- **Use Case:** Best for environments with critical production data where safety is paramount

## Command Line Options

GuardRM supports several command line options:

| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would be deleted without actually deleting |
| `--force-yes` | Skip interactive prompts (use with caution) |
| `--help` | Show help message with usage information |

All standard `rm` options (like `-r`, `-f`, `-v`) are passed through to the underlying `rm` command.

## Running the Tool

After setting up the aliases (see [Installation Instructions](installation.md)), use `rm` or `rmdir` as you normally would. GuardRM will automatically intercept these commands.

### Example: Interactive Mode

Assuming the tool is in interactive mode, if you run:

```bash
rm important_file.txt
```

You will see a colorful output similar to:

```
╔════════════════════════════════════════════════════════════════╗
║  GuardRM - Safe Deletion Protection                          ║
╚════════════════════════════════════════════════════════════════╝

┌────────────────────────────────────────────────────────────────┐
│  ⚠  DELETION WARNING                                          │
├────────────────────────────────────────────────────────────────┤
│  Host:   my-server
│  User:   admin
│  Time:   2024-01-15 10:30:45
│  Target: /path/to/important_file.txt
└────────────────────────────────────────────────────────────────┘
  Type:   File (1.2M)

Proceed with deletion? (y/N):
```

If you type `y`, the file will be deleted. Otherwise, the deletion is canceled.

### Example: Protected Mode

With the configuration set to protected mode and the target file within a protected directory:

```bash
rm /var/www/prod/config.php
```

Will result in:

```
ERROR: Deletion blocked. '/var/www/prod/config.php' is a protected path.
```

### Example: Dry-Run Mode

To preview what would be deleted without actually deleting:

```bash
rm --dry-run *.log
```

Output:
```
ℹ DRY-RUN MODE - No files will be deleted
Would delete:
  → app.log
  → error.log
  → access.log
```

### Example: Force Mode

To skip prompts in scripts (use with caution):

```bash
rm --force-yes temp_file.txt
```

## Configuration

### Configuration File Location

The configuration file is located at `config/safe_rm.json`.

### Configuration Options

```json
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
```

| Option | Type | Description |
|--------|------|-------------|
| `mode` | string | `"interactive"` or `"protected"` |
| `protected_paths` | array | List of absolute paths that are protected from deletion |
| `protected_patterns` | array | List of regex patterns for path matching |
| `enable_logging` | boolean | Enable/disable logging of deletion attempts |
| `prompt_timeout` | number | Timeout in seconds for interactive prompt (0 = no timeout) |

### Pattern-Based Protection

You can use regex patterns to protect files matching specific patterns:

```json
{
    "protected_patterns": [
        ".*\\.production\\..*",
        ".*\\.prod\\.db$",
        ".*/backup/.*"
    ]
}
```

This would protect:
- Any file with `.production.` in its path
- Any file ending with `.prod.db`
- Any file in a `backup` directory

## Logging

When logging is enabled, all deletion attempts are recorded to `logs/safe_rm.log`:

```
[2024-01-15 10:30:45] [admin@my-server] DELETE_ATTEMPT: /tmp/test.txt -> USER_APPROVED
[2024-01-15 10:31:12] [admin@my-server] DELETE_ATTEMPT: /var/www/prod/config.php -> BLOCKED_PROTECTED_PATH
[2024-01-15 10:32:00] [admin@my-server] DELETE: /tmp/test.txt -> SUCCESS
```

Log entries include:
- Timestamp
- User and hostname
- Action type
- Target path
- Result (APPROVED, CANCELLED, BLOCKED, SUCCESS, FAILED)

## Advanced Usage

### Timeout for Interactive Prompts

Set a timeout for interactive prompts (useful for automated environments):

```json
{
    "prompt_timeout": 30
}
```

If no response is received within 30 seconds, the deletion is automatically cancelled.

### Integration with sudo

The alias setup script can configure protection for `sudo rm` commands as well. This creates a wrapper that ensures even elevated deletions go through GuardRM.

For further customizations or additions to the configuration, refer to the [Development Guidelines](development.md).
