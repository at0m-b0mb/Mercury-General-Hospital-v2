#!/usr/bin/env bash
# ==============================================================================
# Mercury General Hospital CTF - Machine 2
# Universal Linux / macOS Installer
#
# Run this once to clone the repo, install Node.js dependencies, and start
# the CTF server — all in a single step.
#
# ONE-LINE INSTALL (run this in your terminal):
#   curl -fsSL https://raw.githubusercontent.com/at0m-b0mb/Mercury-General-Hospital-v2/main/install.sh | bash
#
# Or download and run manually:
#   chmod +x install.sh && ./install.sh
# ==============================================================================

set -e   # exit on any unhandled error

REPO_URL="https://github.com/at0m-b0mb/Mercury-General-Hospital-v2.git"
REPO_BRANCH="main"
INSTALL_DIR="$HOME/ctf/machine-2-hospital"
NODE_URL="https://nodejs.org/en/download/"

# --------------------------------------------------------------------------
# Colour helpers (gracefully degraded if terminal has no colour support)
# --------------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

banner()  { echo -e "${CYAN}${BOLD}$*${RESET}"; }
step()    { echo -e "${YELLOW}[>>] $*${RESET}"; }
ok()      { echo -e "${GREEN}[OK] $*${RESET}"; }
err()     { echo -e "${RED}[ERROR] $*${RESET}"; }
info()    { echo -e "${CYAN}[INFO] $*${RESET}"; }

# --------------------------------------------------------------------------
# 1. Banner
# --------------------------------------------------------------------------
echo ""
banner " =============================================================="
banner "   Mercury General Hospital — CTF Machine 2  |  Installer"
banner " =============================================================="
echo ""

# --------------------------------------------------------------------------
# 2. Detect OS
# --------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="Linux" ;;
  Darwin*)  PLATFORM="macOS" ;;
  *)        PLATFORM="$OS"   ;;
esac
info "Detected platform: $PLATFORM"

# --------------------------------------------------------------------------
# 3. Check for Node.js
# --------------------------------------------------------------------------
step "Checking for Node.js..."
if ! command -v node &>/dev/null; then
    err "Node.js is not installed or not in PATH."
    echo ""
    echo -e "  Install Node.js (v16 LTS or later) from: ${BOLD}${NODE_URL}${RESET}"
    echo ""

    if [ "$PLATFORM" = "Linux" ]; then
        echo -e "  ${YELLOW}Quick install (Debian/Ubuntu):${RESET}"
        echo "    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
        echo "    sudo apt-get install -y nodejs"
        echo ""
        echo -e "  ${YELLOW}Quick install (RHEL/Fedora/CentOS):${RESET}"
        echo "    curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -"
        echo "    sudo dnf install -y nodejs"
    elif [ "$PLATFORM" = "macOS" ]; then
        echo -e "  ${YELLOW}Quick install (Homebrew):${RESET}"
        echo "    brew install node"
    fi
    echo ""
    echo "  After installing Node.js, re-run this script."
    exit 1
fi

NODE_VER="$(node --version)"
ok "Node.js found: $NODE_VER"

# --------------------------------------------------------------------------
# 4. Check for npm
# --------------------------------------------------------------------------
if ! command -v npm &>/dev/null; then
    err "npm is not available. Reinstall Node.js from $NODE_URL"
    exit 1
fi
NPM_VER="$(npm --version)"
ok "npm found: v$NPM_VER"

# --------------------------------------------------------------------------
# 5. Get the source code
#    Case A: Already inside the cloned repo (server.js next to this script)
#    Case B: git is available → clone / pull to $INSTALL_DIR
#    Case C: No git → download tar.gz from GitHub
# --------------------------------------------------------------------------
echo ""
step "Locating source files..."

# Resolve the directory this script lives in, even when piped through bash
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

PROJECT_DIR=""
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/server.js" ]; then
    ok "Source files detected in: $SCRIPT_DIR"
    PROJECT_DIR="$SCRIPT_DIR"
elif [ -f "$(pwd)/server.js" ]; then
    ok "Source files detected in current directory."
    PROJECT_DIR="$(pwd)"
else
    # Try git
    if command -v git &>/dev/null; then
        if [ -d "$INSTALL_DIR/.git" ]; then
            info "Existing clone found at $INSTALL_DIR"
            step "Updating with git pull..."
            git -C "$INSTALL_DIR" pull origin "$REPO_BRANCH"
        else
            step "Cloning repository to $INSTALL_DIR ..."
            mkdir -p "$(dirname "$INSTALL_DIR")"
            git clone --branch "$REPO_BRANCH" "$REPO_URL" "$INSTALL_DIR"
            ok "Repository cloned."
        fi
        PROJECT_DIR="$INSTALL_DIR"
    else
        # Fallback: download tar.gz
        info "git not found — downloading archive from GitHub instead."

        TAR_URL="https://github.com/at0m-b0mb/Mercury-General-Hospital-v2/archive/refs/heads/${REPO_BRANCH}.tar.gz"
        TAR_PATH="/tmp/machine2-ctf.tar.gz"
        EXTRACT_DIR="/tmp/machine2-ctf-extract"

        step "Downloading archive from GitHub..."
        if command -v curl &>/dev/null; then
            curl -fsSL "$TAR_URL" -o "$TAR_PATH"
        elif command -v wget &>/dev/null; then
            wget -q "$TAR_URL" -O "$TAR_PATH"
        else
            err "Neither curl nor wget found. Install one of them and re-run."
            exit 1
        fi

        step "Extracting archive..."
        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        tar -xzf "$TAR_PATH" -C "$EXTRACT_DIR"

        EXTRACTED="$(ls -1 "$EXTRACT_DIR" | head -n1)"
        if [ -z "$EXTRACTED" ]; then
            err "Could not find extracted folder."
            exit 1
        fi

        rm -rf "$INSTALL_DIR"
        mkdir -p "$(dirname "$INSTALL_DIR")"
        mv "$EXTRACT_DIR/$EXTRACTED" "$INSTALL_DIR"
        ok "Files extracted to $INSTALL_DIR"
        PROJECT_DIR="$INSTALL_DIR"
    fi
fi

cd "$PROJECT_DIR"

# --------------------------------------------------------------------------
# 6. Install npm dependencies
# --------------------------------------------------------------------------
echo ""
step "Installing Node.js dependencies (npm install)..."
npm install
ok "Dependencies installed."

# --------------------------------------------------------------------------
# 7. Copy .env.example → .env (if not already present)
# --------------------------------------------------------------------------
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    cp .env.example .env
    ok ".env created from .env.example"
fi

# --------------------------------------------------------------------------
# 8. Choose port
# --------------------------------------------------------------------------
echo ""
read -r -p "Enter port to run the server on (press ENTER for default 3000): " PORT_INPUT
if [ -z "$PORT_INPUT" ]; then
    PORT_INPUT=3000
fi

# Warn if trying to use port <1024 without root
if [ "$PORT_INPUT" -lt 1024 ] 2>/dev/null && [ "$(id -u)" -ne 0 ]; then
    echo ""
    echo -e "${YELLOW}[WARN] Port $PORT_INPUT requires root privileges on Linux/macOS.${RESET}"
    echo -e "       ${YELLOW}Use 'sudo' or choose a port >= 1024 (e.g. 3000 or 8080).${RESET}"
    echo ""
    read -r -p "Continue anyway? [y/N]: " CONTINUE
    case "$CONTINUE" in
        [yY]*) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
fi

# --------------------------------------------------------------------------
# 9. Summary
# --------------------------------------------------------------------------
echo ""
banner " =============================================================="
banner "  Setup complete!"
banner " =============================================================="
echo ""
info "Project folder : $PROJECT_DIR"
info "Server port    : $PORT_INPUT"
info "URL            : http://localhost:$PORT_INPUT"
echo ""
echo -e "${YELLOW}  The server will start now.${RESET}"
echo -e "${CYAN}  Open your browser to: http://localhost:${PORT_INPUT}${RESET}"
echo -e "${YELLOW}  Press Ctrl+C to stop the server at any time.${RESET}"
echo ""

# --------------------------------------------------------------------------
# 10. Start the server
# --------------------------------------------------------------------------
export PORT="$PORT_INPUT"
node server.js
