#!/bin/bash
# alias_setup.sh
# Sets up shell aliases for the safe_rm tool to intercept rm and rmdir commands.
# Features:
# - Automatic shell detection (bash, zsh, fish)
# - sudo wrapper support
# - Colored output for better visibility

# ============================================================================
# Color Definitions
# ============================================================================
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ============================================================================
# Functions
# ============================================================================

print_banner() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}  ${BOLD}${CYAN}GuardRM${RESET} - Setup Wizard                                      ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

print_success() {
    echo -e "${GREEN}${BOLD}✓${RESET} ${GREEN}$1${RESET}"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ${RESET} ${BLUE}$1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠${RESET} ${YELLOW}$1${RESET}"
}

print_error() {
    echo -e "${RED}${BOLD}✗${RESET} ${RED}$1${RESET}"
}

# Determine the absolute path of safe_rm.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAFE_RM_SCRIPT="$SCRIPT_DIR/safe_rm.sh"

# ============================================================================
# Main Setup
# ============================================================================

print_banner

# Verify safe_rm.sh exists and is executable
if [[ ! -f "$SAFE_RM_SCRIPT" ]]; then
    print_error "safe_rm.sh not found at $SAFE_RM_SCRIPT"
    exit 1
fi

if [[ ! -x "$SAFE_RM_SCRIPT" ]]; then
    print_info "Making safe_rm.sh executable..."
    chmod +x "$SAFE_RM_SCRIPT"
fi

print_success "Found safe_rm.sh at: $SAFE_RM_SCRIPT"
echo ""

# Set up aliases for current session
print_info "Setting up safe-rm aliases for current session..."
alias rm="$SAFE_RM_SCRIPT"
alias rmdir="$SAFE_RM_SCRIPT"
print_success "Aliases set for current session"
echo ""

# Offer to add the aliases permanently
echo -e "${BOLD}Would you like to add these aliases permanently to your shell configuration?${RESET}"
echo "This will intercept rm and rmdir commands with safe-rm protection."
echo ""
read -p "Add permanent aliases? (y/N): " -r add_alias
echo ""

if [[ "$add_alias" =~ ^[Yy]$ ]]; then
    # Detect the shell to choose the appropriate config file
    SHELL_NAME=$(basename "$SHELL")
    
    case "$SHELL_NAME" in
        bash)
            CONFIG_FILE="$HOME/.bashrc"
            ;;
        zsh)
            CONFIG_FILE="$HOME/.zshrc"
            ;;
        fish)
            CONFIG_FILE="$HOME/.config/fish/config.fish"
            FISH_MODE=true
            ;;
        *)
            print_warning "Unsupported shell: $SHELL_NAME"
            echo ""
            echo "Please add the following lines to your shell configuration manually:"
            echo -e "  ${CYAN}alias rm=\"$SAFE_RM_SCRIPT\"${RESET}"
            echo -e "  ${CYAN}alias rmdir=\"$SAFE_RM_SCRIPT\"${RESET}"
            exit 0
            ;;
    esac
    
    # Check if aliases already exist
    if grep -q "alias rm=\"$SAFE_RM_SCRIPT\"" "$CONFIG_FILE" 2>/dev/null; then
        print_warning "Aliases already exist in $CONFIG_FILE"
    else
        # Create backup
        if [[ -f "$CONFIG_FILE" ]]; then
            cp "$CONFIG_FILE" "${CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
            print_info "Created backup of $CONFIG_FILE"
        fi
        
        # Add aliases based on shell type
        echo "" >> "$CONFIG_FILE"
        echo "# GuardRM - Safe deletion protection" >> "$CONFIG_FILE"
        
        if [[ "$FISH_MODE" == "true" ]]; then
            echo "alias rm \"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
            echo "alias rmdir \"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
        else
            echo "alias rm=\"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
            echo "alias rmdir=\"$SAFE_RM_SCRIPT\"" >> "$CONFIG_FILE"
        fi
        
        print_success "Aliases added to $CONFIG_FILE"
    fi
    
    echo ""
    echo -e "${BOLD}Setup Complete!${RESET}"
    echo ""
    echo "To activate the changes, either:"
    echo -e "  ${CYAN}1.${RESET} Restart your terminal"
    echo -e "  ${CYAN}2.${RESET} Run: ${CYAN}source $CONFIG_FILE${RESET}"
    echo ""
    
    # Offer sudo protection setup
    echo -e "${BOLD}Would you like to also protect sudo rm commands?${RESET}"
    echo "This creates a wrapper function that intercepts 'sudo rm' as well."
    echo ""
    read -p "Add sudo protection? (y/N): " -r add_sudo
    
    if [[ "$add_sudo" =~ ^[Yy]$ ]]; then
        SUDO_WRAPPER='
# GuardRM - Sudo protection wrapper
guard_sudo() {
    if [[ "$1" == "rm" || "$1" == "rmdir" ]]; then
        shift
        sudo '"$SAFE_RM_SCRIPT"' "$@"
    else
        command sudo "$@"
    fi
}
alias sudo=guard_sudo'
        
        if [[ "$FISH_MODE" == "true" ]]; then
            print_warning "Sudo wrapper for fish shell requires manual setup"
        else
            if ! grep -q "guard_sudo" "$CONFIG_FILE" 2>/dev/null; then
                echo "$SUDO_WRAPPER" >> "$CONFIG_FILE"
                print_success "Sudo protection added"
            else
                print_warning "Sudo protection already configured"
            fi
        fi
    fi
    
else
    echo "Aliases not added permanently."
    echo ""
    echo "To activate safe-rm protection manually, add these lines to your shell config:"
    echo -e "  ${CYAN}alias rm=\"$SAFE_RM_SCRIPT\"${RESET}"
    echo -e "  ${CYAN}alias rmdir=\"$SAFE_RM_SCRIPT\"${RESET}"
fi

echo ""
print_success "GuardRM setup complete!"
echo ""
echo "For usage information, run: ${CYAN}$SAFE_RM_SCRIPT --help${RESET}"
