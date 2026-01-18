#!/bin/bash
# alias_setup.sh
# Sets up shell aliases for the safe_rm tool to intercept rm and rmdir commands.

# Determine the absolute path of safe_rm.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAFE_RM_SCRIPT="$SCRIPT_DIR/safe_rm.sh"

echo "Setting up safe-rm aliases..."
alias rm="$SAFE_RM_SCRIPT"
alias rmdir="$SAFE_RM_SCRIPT"

# Offer to add the aliases permanently by appending them to your shell configuration file.
echo "Do you want to add these aliases to your shell configuration file? (y/N)"
read -r add_alias

if [[ "$add_alias" =~ ^[Yy]$ ]]; then
    # Detect the shell to choose the appropriate config file
    SHELL_NAME=$(basename "$SHELL")
    if [[ "$SHELL_NAME" == "bash" ]]; then
        CONFIG_FILE="$HOME/.bashrc"
    elif [[ "$SHELL_NAME" == "zsh" ]]; then
        CONFIG_FILE="$HOME/.zshrc"
    else
        echo "Unsupported shell: $SHELL_NAME. Please add the following lines manually:"
        echo "alias rm=\"$SAFE_RM_SCRIPT\""
        echo "alias rmdir=\"$SAFE_RM_SCRIPT\""
        exit 0
    fi
    echo "alias rm=\"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
    echo "alias rmdir=\"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
    echo "Aliases added to $CONFIG_FILE. Please restart your shell to activate them."
else
    echo "Aliases not added. To activate the safe-rm tool, add the following lines to your shell configuration:"
    echo "alias rm=\"$SAFE_RM_SCRIPT\""
    echo "alias rmdir=\"$SAFE_RM_SCRIPT\""
fi
