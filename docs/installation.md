# Installation Instructions

This document provides detailed instructions for installing and setting up the safe-rm tool on your system.

## Prerequisites

- **jq:** The tool relies on the [`jq`](https://stedolan.github.io/jq/) JSON parser for reading configuration files. Ensure that it is installed on your system:
  ```bash
  sudo apt-get install jq      # For Debian/Ubuntu systems
  sudo yum install jq          # For RHEL/CentOS systems
  ```
- **Bash:** The safe-rm tool is written in Bash and requires a POSIX-compliant shell.
- **Permissions:** Ensure you have sufficient privileges to modify shell configuration files if you opt for a permanent alias setup.

## Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/djeada/GuardRM.git
cd GuardRM
```

## Configuration File

A default configuration file is provided in the `config/` folder. You can customize it to define protected paths and choose between interactive or protected modes. See [Usage Guide](usage.md) for more details.

## Setup Aliases

The safe-rm tool uses shell aliases to intercept calls to `rm` and `rmdir`. To set them up, run the alias setup script:

```bash
cd scripts
./alias_setup.sh
```

This script will temporarily set the aliases and provide an option to add them permanently to your shell configuration (e.g., `~/.bashrc` or `~/.zshrc`).

## Final Check

After setting up the aliases, you can test the tool by trying to remove a test file. The tool should either prompt you with a warning (in interactive mode) or prevent deletion for paths defined in your configuration file (in protected mode).

If you encounter any issues during installation, please consult the [Development Guidelines](development.md) for troubleshooting tips or reach out to the repository maintainers.
