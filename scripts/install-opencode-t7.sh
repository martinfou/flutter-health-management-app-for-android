#!/usr/bin/env bash
# OpenCode Installation Script for T7 External Drive
# Installs OpenCode to /Volumes/T7/Applications/opencode and sets up symlinks and environment variables

set -euo pipefail

INSTALL_DIR="/Volumes/T7/Applications/opencode/bin"
CONFIG_DIR="/Volumes/T7/Applications/opencode/config"
DATA_DIR="/Volumes/T7/Applications/opencode/data"
SYMLINK_DIR="$HOME/bin"
SHELL_CONFIG="$HOME/.zshrc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_message() {
    local level=$1
    shift
    case $level in
        info)
            echo -e "${GREEN}[INFO]${NC} $*"
            ;;
        warning)
            echo -e "${YELLOW}[WARNING]${NC} $*"
            ;;
        error)
            echo -e "${RED}[ERROR]${NC} $*"
            ;;
        step)
            echo -e "${BLUE}[STEP]${NC} $*"
            ;;
    esac
}

# Check if T7 drive is mounted
if [ ! -d "/Volumes/T7" ]; then
    print_message error "T7 drive is not mounted at /Volumes/T7"
    exit 1
fi

# Check if T7 Applications directory exists, create if not
print_message step "Creating installation directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$SYMLINK_DIR"

# Detect OS and architecture
raw_os=$(uname -s)
os=$(echo "$raw_os" | tr '[:upper:]' '[:lower:]')
case "$raw_os" in
  Darwin*) os="darwin" ;;
  Linux*) os="linux" ;;
  *)
    print_message error "Unsupported OS: $raw_os"
    exit 1
    ;;
esac

arch=$(uname -m)
case "$arch" in
  x86_64|amd64)
    if [ "$os" = "darwin" ]; then
      arch="x64"
    else
      arch="amd64"
    fi
    ;;
  arm64|aarch64)
    if [ "$os" = "darwin" ]; then
      arch="arm64"
    else
      arch="arm64"
    fi
    ;;
  *)
    print_message error "Unsupported architecture: $arch"
    exit 1
    ;;
esac

# Determine file extension and extraction method
if [ "$os" = "darwin" ]; then
    filename="opencode-${os}-${arch}.zip"
    extract_cmd="unzip -q"
    need_unzip=true
elif [ "$os" = "linux" ]; then
    filename="opencode-${os}-${arch}.tar.gz"
    extract_cmd="tar -xzf"
    need_tar=true
else
    print_message error "Unknown OS: $os"
    exit 1
fi

# Check for required tools
if [ "${need_unzip:-false}" = "true" ]; then
    if ! command -v unzip &> /dev/null; then
        print_message error "'unzip' is required but not installed."
        exit 1
    fi
fi

if [ "${need_tar:-false}" = "true" ]; then
    if ! command -v tar &> /dev/null; then
        print_message error "'tar' is required but not installed."
        exit 1
    fi
fi

# Download and install OpenCode
print_message step "Fetching latest OpenCode version..."
tmp_dir=$(mktemp -d)
trap "rm -rf $tmp_dir" EXIT

# Get the latest version tag
latest_version=$(curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')

if [[ -z "$latest_version" ]]; then
    print_message error "Failed to fetch latest version information"
    exit 1
fi

print_message info "Latest version: $latest_version"

# Construct download URL with version tag
url="https://github.com/anomalyco/opencode/releases/download/v${latest_version}/$filename"
print_message step "Downloading OpenCode from: $url"

if ! curl -fsSL -o "$tmp_dir/$filename" "$url"; then
    print_message error "Failed to download OpenCode"
    print_message info "Tried URL: $url"
    exit 1
fi

print_message step "Extracting OpenCode..."
if [ "$os" = "darwin" ]; then
    unzip -q "$tmp_dir/$filename" -d "$tmp_dir"
else
    tar -xzf "$tmp_dir/$filename" -C "$tmp_dir"
fi

print_message step "Installing OpenCode to $INSTALL_DIR..."
mv "$tmp_dir/opencode" "$INSTALL_DIR/opencode"
chmod +x "${INSTALL_DIR}/opencode"

print_message info "OpenCode installed successfully to $INSTALL_DIR"

# Create symlink in ~/bin
print_message step "Creating symlink in $SYMLINK_DIR..."
if [ -L "$SYMLINK_DIR/opencode" ] || [ -f "$SYMLINK_DIR/opencode" ]; then
    print_message warning "Symlink or file already exists at $SYMLINK_DIR/opencode, removing..."
    rm -f "$SYMLINK_DIR/opencode"
fi

ln -sf "$INSTALL_DIR/opencode" "$SYMLINK_DIR/opencode"
print_message info "Symlink created: $SYMLINK_DIR/opencode -> $INSTALL_DIR/opencode"

# Ensure ~/bin is in PATH
print_message step "Adding ~/bin to PATH if not already present..."
if ! echo "$PATH" | grep -q "$SYMLINK_DIR"; then
    if [ -f "$SHELL_CONFIG" ]; then
        if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$SHELL_CONFIG"; then
            echo '' >> "$SHELL_CONFIG"
            echo '# Add ~/bin to PATH for OpenCode and other custom binaries' >> "$SHELL_CONFIG"
            echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_CONFIG"
            print_message info "Added ~/bin to PATH in $SHELL_CONFIG"
        else
            print_message info "~/bin already in PATH in $SHELL_CONFIG"
        fi
    else
        print_message warning "$SHELL_CONFIG not found, creating it..."
        echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_CONFIG"
    fi
else
    print_message info "~/bin is already in PATH"
fi

# Set up environment variables
print_message step "Setting up environment variables..."

# Check if environment variables are already set
env_setup=""
if ! grep -q 'export OPENCODE_CONFIG_DIR=' "$SHELL_CONFIG" 2>/dev/null; then
    env_setup="$env_setup
export OPENCODE_CONFIG_DIR=\"$CONFIG_DIR\""
fi

if ! grep -q 'export OPENCODE_DATA_DIR=' "$SHELL_CONFIG" 2>/dev/null; then
    env_setup="$env_setup
export OPENCODE_DATA_DIR=\"$DATA_DIR\""
fi

if [ -n "$env_setup" ]; then
    echo '' >> "$SHELL_CONFIG"
    echo '# OpenCode environment variables' >> "$SHELL_CONFIG"
    echo "$env_setup" >> "$SHELL_CONFIG"
    print_message info "Added OpenCode environment variables to $SHELL_CONFIG"
else
    print_message info "OpenCode environment variables already configured"
fi

# Export environment variables for current session
export OPENCODE_CONFIG_DIR="$CONFIG_DIR"
export OPENCODE_DATA_DIR="$DATA_DIR"
export PATH="$SYMLINK_DIR:$PATH"

# Verify installation
print_message step "Verifying installation..."
if [ -x "$INSTALL_DIR/opencode" ]; then
    version=$("$INSTALL_DIR/opencode" --version 2>&1 || echo "unknown")
    print_message info "OpenCode version: $version"
else
    print_message error "OpenCode binary not found or not executable"
    exit 1
fi

if command -v opencode &> /dev/null; then
    print_message info "OpenCode command is available: $(which opencode)"
else
    print_message warning "OpenCode command not found in PATH. Run: source $SHELL_CONFIG"
fi

# Summary
echo ""
print_message info "═══════════════════════════════════════════════════════════"
print_message info "OpenCode Installation Complete!"
print_message info "═══════════════════════════════════════════════════════════"
echo ""
print_message info "Installation directory: $INSTALL_DIR"
print_message info "Configuration directory: $CONFIG_DIR"
print_message info "Data directory: $DATA_DIR"
print_message info "Symlink: $SYMLINK_DIR/opencode"
echo ""
print_message info "To use OpenCode in your current terminal session, run:"
print_message step "  source $SHELL_CONFIG"
echo ""
print_message info "Or open a new terminal window."
echo ""
print_message info "To start using OpenCode:"
print_message step "  cd <your-project>"
print_message step "  opencode"
echo ""
print_message info "For more information visit: https://opencode.ai/docs"
echo ""

