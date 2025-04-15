# Usage Guide

This document explains how to use the safe-rm tool to intercept and secure removal operations on your system.

## Modes of Operation

The tool operates in two main modes based on the JSON configuration in `config/safe_rm.json`:

1. **Interactive Mode:**  
   - **Behavior:** When executing a deletion command, the tool prints a warning message showing the current host and the absolute path of the target file/folder.
   - **Prompt:** The user is prompted to confirm the deletion.
   - **Use Case:** Ideal for everyday use where a simple prompt helps prevent accidental deletions.

2. **Protected Mode:**  
   - **Behavior:** The tool blocks deletion of files or directories that match any of the protected paths defined in the configuration.
   - **Error Message:** An error message is displayed if a deletion is attempted on a protected path.
   - **Use Case:** Best for environments with critical production data where safety is paramount.

## Running the Tool

After setting up the aliases (see [Installation Instructions](installation.md)), use `rm` or `rmdir` as you normally would. The safe-rm tool will automatically intercept these commands.

### Example: Interactive Mode

Assuming the tool is in interactive mode, if you run:

```bash
rm important_file.txt
```

You will see an output similar to:

```
YOU ARE ON HOST: my-server
YOU WANT TO DELETE: /absolute/path/to/important_file.txt
Proceed with deletion? (y/N):
```

If you type `y`, the file will be deleted. Otherwise, the deletion is canceled.

### Example: Protected Mode

With the configuration set to protected mode and the target file within a protected directory, attempting:

```bash
rm /path/to/protected_data/file.txt
```

Will result in:

```
ERROR: Deletion blocked. '/path/to/protected_data/file.txt' is a protected path.
```

## Customizing Configuration

Edit the `config/safe_rm.json` file to switch modes and define which paths are protected. For example:

```json
{
    "mode": "protected",
    "protected_paths": ["/var/www/prod", "/data/critical"]
}
```

Changing `"mode"` from `"protected"` to `"interactive"` will enable the interactive confirmation feature instead.

For further customizations or additions to the configuration, refer to the [Development Guidelines](development.md).
