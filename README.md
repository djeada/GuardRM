# GuardRM

A lightweight, yet robust safeguard against accidental deletion of critical production data. GuardRM intercepts and wraps native removal commands (`rm` and `rmdir`), providing a two-tiered defense mechanism through interactive warnings and configurable path protection.

![guard_rm](https://github.com/user-attachments/assets/46510f32-0145-42d5-a3e4-16fb84365eb8)

## ✨ Features

- **Interactive Mode**: Displays colorful warnings with host, user, timestamp, and target path before deletion
- **Protected Mode**: Blocks deletion of critical directories based on JSON configuration
- **Pattern Protection**: Use regex patterns to protect files matching specific naming conventions
- **Dry-Run Mode**: Preview what would be deleted without actually deleting (`--dry-run`)
- **Logging**: Comprehensive logging of all deletion attempts and outcomes
- **Color-Coded Output**: Beautiful, informative terminal output with Unicode symbols
- **Multiple Shell Support**: Works with Bash, Zsh, and Fish
- **Sudo Protection**: Optional wrapper for `sudo rm` commands

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/djeada/GuardRM.git
cd GuardRM

# Make scripts executable
chmod +x scripts/*.sh

# Run the setup wizard
./scripts/alias_setup.sh
```

### Basic Usage

```bash
# Interactive mode - prompts before deletion
rm important_file.txt

# Dry-run - see what would be deleted
rm --dry-run *.log

# Skip prompts (use with caution)
rm --force-yes temp_file.txt

# Show help
rm --help
```

## ⚙️ Configuration

Edit `config/safe_rm.json` to customize behavior:

```json
{
    "mode": "interactive",
    "protected_paths": [
        "/var/www/prod",
        "/data/critical"
    ],
    "protected_patterns": [
        ".*\\.production\\..*",
        ".*\\.prod\\.db$"
    ],
    "enable_logging": true,
    "prompt_timeout": 0
}
```

### Configuration Options

| Option | Description |
|--------|-------------|
| `mode` | `"interactive"` (prompt before delete) or `"protected"` (block protected paths) |
| `protected_paths` | Array of absolute paths to protect from deletion |
| `protected_patterns` | Array of regex patterns for path matching |
| `enable_logging` | Enable/disable logging to `logs/safe_rm.log` |
| `prompt_timeout` | Timeout in seconds for interactive prompt (0 = no timeout) |

## 📖 Documentation

- [Installation Guide](docs/installation.md) - Detailed setup instructions
- [Usage Guide](docs/usage.md) - Complete usage documentation
- [Development Guidelines](docs/development.md) - Contributing guide

## 🧪 Testing

```bash
cd tests
./test_cases.sh
```

The test suite covers:
- Interactive mode cancellation
- Protected mode blocking
- Dry-run mode
- Pattern-based protection
- Multiple target handling
- Logging functionality

## 🛡️ Safety Features

1. **Visual Warnings**: Clear, colorful output showing exactly what will be deleted
2. **Path Protection**: Block deletion of critical system and production directories
3. **Pattern Matching**: Protect files matching regex patterns (e.g., `*.production.*`)
4. **Logging**: Audit trail of all deletion attempts
5. **Dry-Run**: Test deletion commands safely
6. **Timeout**: Auto-cancel deletions if no response (configurable)

## 📋 Requirements

- **Bash** 4.0+ (or Zsh/Fish)
- **jq** - JSON parser ([installation](https://stedolan.github.io/jq/download/))

## 🤝 Contributing

Contributions are welcome! Please read our [Development Guidelines](docs/development.md) before submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
