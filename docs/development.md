# Development Guidelines

This document provides guidelines for contributing to and extending the safe-rm tool. Whether you are fixing bugs, adding new features, or improving documentation, this guide will help maintain consistency and quality across the project.

## Repository Structure

- **docs/**: Contains all documentation files.  
  - `installation.md`: Setup and installation instructions.  
  - `usage.md`: User guide and usage examples.  
  - `development.md`: Guidelines for contributing.

- **config/**: Contains default configuration files.  
  - `safe_rm.json`: JSON configuration file to define protected paths and operational mode.

- **scripts/**: Contains the main Bash scripts and helper functions.  
  - `safe_rm.sh`: Core script intercepting `rm`/`rmdir` commands.  
  - `alias_setup.sh`: Script for setting up shell aliases.

- **tests/**: Contains automated tests for the tool.  
  - `test_cases.sh`: Test cases covering deletion scenarios and configurations.  
  - `test_setup.sh`: Scripts to set up a test environment.

## Coding Standards

- **Bash Style:**  
  - Use `#!/bin/bash` as the interpreter.
  - Use clear variable names and include inline comments where needed.
  - Ensure that scripts are executable (`chmod +x`).

- **Documentation:**  
  - Update the corresponding Markdown files in `docs/` for any significant changes.
  - Keep the user guide and installation instructions up to date with new features or changes.

## Testing

- **Automated Tests:**  
  - Run tests locally using the scripts in the `tests/` directory.
  - Use `tests/test_setup.sh` to prepare the testing environment, then run `tests/test_cases.sh` to execute the test cases.
  
- **Test Coverage:**  
  - Ensure that all new features are accompanied by corresponding tests.
  - Validate both interactive and protected modes with a variety of deletion scenarios.

## Pull Requests and Contributions

- **Branching:**  
  - Follow the Git branching model used in the repository. For example, work on feature branches and open pull requests against the main branch.
  
- **Commit Messages:**  
  - Write clear and descriptive commit messages that reference the changes or issues addressed.
  
- **Code Reviews:**  
  - Participate actively in code reviews. Ensure that your code meets the coding standards and passes all tests.
  
- **Feature Requests:**  
  - If you are proposing a major change, open an issue first to discuss the design and gather feedback from the community.

## Future Enhancements

Consider the following areas when extending the tool:
- **Logging:** Implement detailed logging for deletion attempts and actions taken.
- **Additional Config Options:** Expand the JSON configuration to include more granular control (e.g., specifying user roles, time-based rules).
- **CI/CD Integration:** Add automated checks and deployment pipelines.
- **Enhanced UI:** Improve the interactive prompt, possibly with timeout options or additional safety confirmation layers.
  
We welcome contributions and improvements that help make safe-rm a more robust and versatile tool for managing production data safely.
