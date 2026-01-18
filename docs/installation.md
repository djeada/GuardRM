# Installation Instructions

This document provides detailed instructions for installing and setting up GuardRM on your system.

## Prerequisites

- **jq:** The tool relies on the [`jq`](https://stedolan.github.io/jq/) JSON parser for reading configuration files. Ensure that it is installed on your system:
  ```bash
  # Debian/Ubuntu
  sudo apt-get install jq
  
  # RHEL/CentOS
  sudo yum install jq
  
  # macOS
  brew install jq
  ```
- **Bash:** GuardRM is written in Bash and requires a POSIX-compliant shell (Bash 4.0+, Zsh, or compatible).
- **Permissions:** Ensure you have sufficient privileges to modify shell configuration files if you opt for a permanent alias setup.

## Quick Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/djeada/GuardRM.git
cd GuardRM
```

### Step 2: Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### Step 3: Run the Setup Wizard

```bash
./scripts/alias_setup.sh
```

The setup wizard will:
1. Set up temporary aliases for your current session
2. Offer to add permanent aliases to your shell configuration
3. Optionally configure protection for `sudo rm` commands

## Manual Installation

If you prefer to set up manually, add these lines to your shell configuration file (`~/.bashrc`, `~/.zshrc`, or similar):

```bash
# GuardRM - Safe deletion protection
alias rm="/path/to/GuardRM/scripts/safe_rm.sh"
alias rmdir="/path/to/GuardRM/scripts/safe_rm.sh"
```

Then reload your shell configuration:

```bash
source ~/.bashrc  # or ~/.zshrc
```

## Configuration File

A default configuration file is provided in the `config/` folder. You can customize it to define protected paths and choose between interactive or protected modes.

### Default Configuration

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

See [Usage Guide](usage.md) for detailed configuration options.

## Directory Structure

After installation, the GuardRM directory structure is:

```
GuardRM/
├── config/
│   └── safe_rm.json      # Configuration file
├── docs/
│   ├── development.md    # Development guidelines
│   ├── installation.md   # This file
│   └── usage.md          # Usage guide
├── logs/
│   └── safe_rm.log       # Deletion attempt logs (when enabled)
├── scripts/
│   ├── alias_setup.sh    # Setup wizard
│   └── safe_rm.sh        # Main protection script
└── tests/
    ├── test_cases.sh     # Automated tests
    └── test_setup.sh     # Test environment setup
```

## Verification

After setting up the aliases, verify the installation:

```bash
# Check if the alias is active
type rm

# Test the help option
rm --help

# Test dry-run mode (safe - won't delete anything)
touch /tmp/test_guard_rm.txt
rm --dry-run /tmp/test_guard_rm.txt
rm /tmp/test_guard_rm.txt  # Clean up with actual rm
```

## Shell Compatibility

GuardRM supports:
- **Bash** (4.0+)
- **Zsh**
- **Fish** (with minor configuration differences)

## Troubleshooting

### "jq: command not found"
Install jq using your package manager (see Prerequisites).

### Aliases not working
1. Ensure the aliases are in your shell config file
2. Reload the configuration: `source ~/.bashrc` (or `~/.zshrc`)
3. Open a new terminal window

### Permission denied
Make sure the scripts are executable:
```bash
chmod +x /path/to/GuardRM/scripts/*.sh
```

### Colors not displaying
GuardRM automatically disables colors when output is not a terminal (e.g., piped to a file). Colors should display correctly in interactive terminal sessions.

If you encounter any other issues during installation, please consult the [Development Guidelines](development.md) or open an issue on GitHub.
