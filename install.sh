#!/usr/bin/env bash

set -e

# --- Helper Functions ---

# Function to check Neovim version and decide if installation is needed
check_and_install_neovim() {
  local REQUIRED_NVIM_VERSION="0.9.0"
  local LATEST_STABLE_NVIM_VERSION="v0.10.0" # Use a recent stable version for local install
  NEOVIM_OK=false

  if command -v nvim >/dev/null 2>&1; then
    # Neovim is installed, let's check the version
    CURRENT_NVIM_VERSION=$(nvim --version | head -n 1 | cut -d ' ' -f 2 | sed 's/v//')
    # Compare versions using sort -V which handles version numbers correctly
    if [ "$(printf '%s\n' "$REQUIRED_NVIM_VERSION" "$CURRENT_NVIM_VERSION" | sort -V | head -n 1)" = "$REQUIRED_NVIM_VERSION" ]; then
      echo "Neovim found (version $CURRENT_NVIM_VERSION), which meets the requirement (>= $REQUIRED_NVIM_VERSION)."
      NEOVIM_OK=true
    else
      echo "WARNING: Installed Neovim version ($CURRENT_NVIM_VERSION) is too old. An update is required."
    fi
  else
    echo "Neovim not found."
  fi

  # In LOCAL mode, if nvim is not okay, we install it locally
  if [ "$LOCAL_INSTALL" = true ] && [ "$NEOVIM_OK" = false ]; then
    echo "Installing Neovim ${LATEST_STABLE_NVIM_VERSION} locally..."
    cd /tmp
    curl -LO "https://github.com/neovim/neovim/releases/download/${LATEST_STABLE_NVIM_VERSION}/nvim-linux64.tar.gz"
    tar xzf nvim-linux64.tar.gz
    # Ensure local directories exist
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share"
    # Copy files and ensure the binary is in the right place
    cp -r nvim-linux64/bin/* "$HOME/.local/bin/"
    cp -r nvim-linux64/lib/* "$HOME/.local/lib/"
    cp -r nvim-linux64/share/* "$HOME/.local/share/"
    rm -rf nvim-linux64*
    # Add local bin to PATH for the current session
    export PATH="$HOME/.local/bin:$PATH"
    echo "Neovim installed locally."
    NEOVIM_OK=true # Mark as resolved for the rest of the script
  fi

  # In SYSTEM mode, if nvim is not okay, we add the PPA and install
  if [ "$LOCAL_INSTALL" = false ] && [ "$NEOVIM_OK" = false ]; then
    echo "Adding Neovim PPA to get the latest version..."
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    # The main install command later will handle installing 'neovim'
  fi
}

# --- Main Script ---

# Parse command line arguments
LOCAL_INSTALL=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -l|--local)
      LOCAL_INSTALL=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  -l, --local    Install LunarVim locally (without sudo)"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

echo "=== LunarVim Ultimate Installer (Ubuntu/Debian) ==="

if [ "$LOCAL_INSTALL" = true ]; then
  echo "Installing in LOCAL mode (no sudo required)..."

  # Create local directories
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"

  echo "Checking for required dependencies..."

  if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not installed." >&2
    exit 1
  fi
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is required but not installed." >&2
    exit 1
  fi

  # Check and install Neovim if needed
  check_and_install_neovim

  # Install other dependencies locally if not available
  if ! command -v rg >/dev/null 2>&1; then
    echo "Installing ripgrep locally..."
    RG_VERSION="13.0.0"
    cd /tmp
    curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar xzf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    cp "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg" "$HOME/.local/bin/"
    rm -rf ripgrep-*
  fi

  if ! command -v fd >/dev/null 2>&1; then
    echo "Installing fd locally..."
    FD_VERSION="8.7.0"
    cd /tmp
    curl -LO "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar xzf "fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    cp "fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd" "$HOME/.local/bin/"
    rm -rf fd-*
  fi

  if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js locally..."
    curl -L https://bit.ly/n-install | N_PREFIX="$HOME/.local" bash -s -- -y latest
  fi

  # Add local bin to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "Added $HOME/.local/bin to PATH in .bashrc"
  fi

else
  echo "Installing in SYSTEM mode (requires sudo)..."
  echo "Updating package list..."

  # Run apt update and check for GPG errors, redirecting ALL output to the log file
  if ! sudo apt update &> /tmp/apt_error.log; then
      # Check for a generic GPG key error
      if grep -q -i "NO_PUBKEY" /tmp/apt_error.log; then
          # Extract the first missing key ID from the log
          KEY_ID=$(grep -o -i 'NO_PUBKEY [0-9A-F]*' /tmp/apt_error.log | head -n 1 | awk '{print $2}')
          if [[ ! -z "$KEY_ID" ]]; then
              echo "GPG key error detected for key ${KEY_ID}. Attempting to fix automatically..."
              sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${KEY_ID}"
              echo "Re-running package list update..."
              sudo apt update
          else
              # This case is unlikely if the first grep passed, but it's good practice
              echo "Could not extract a GPG Key ID, though an error was detected. Please check the log:" >&2
              cat /tmp/apt_error.log >&2
              exit 1
          fi
      else
          echo "An unknown error occurred during 'apt update'. Please check the full log below:" >&2
          cat /tmp/apt_error.log >&2
          exit 1
      fi
  fi
  rm -f /tmp/apt_error.log

  # Check Neovim version and add PPA if necessary
  check_and_install_neovim

  echo "Installing system dependencies..."
  sudo apt install -y curl git neovim nodejs npm python3-pip ripgrep fd-find unzip
fi

# Install Rust if missing
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

echo "Backing up any previous Neovim/LunarVim config..."
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup.$(date +%s)
[ -d ~/.local/share/lunarvim ] && mv ~/.local/share/lunarvim ~/.local/share/lunarvim.backup.$(date +%s)
[ -d ~/.config/lvim ] && mv ~/.config/lvim ~/.config/lvim.backup.$(date +%s)

echo "Installing LunarVim..."
# Ensure local path is used if in local mode
if [ "$LOCAL_INSTALL" = true ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --yes

echo "Adding recommended plugins to config.lua..."

CONFIG_DIR="$HOME/.config/lvim"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.lua" <<EOF
-- For additional information, see lunarvim's documentation
-- https://www.lunarvim.org/docs/configuration
lvim.plugins = {
  {"nvim-tree/nvim-tree.lua"},
  {"nvim-telescope/telescope.nvim"},
  {"neovim/nvim-lspconfig"},
  {"github/copilot.vim"},
  {"Exafunction/codeium.vim"},
}

-- nvim-tree setup
require("nvim-tree").setup{}
EOF

echo "Testing lvim launch to trigger plugin installation..."
if command -v lvim >/dev/null 2>&1; then
  # Launch lvim headless to install plugins and quit
  timeout 30 lvim --headless "+Lazy! sync" +qa || echo "Lvim test command finished (it may report an error, this is often normal)."
  echo "LunarVim was launched to finalize plugin installation."
else
  echo "ERROR: lvim not found in PATH after installation!" >&2
  exit 1
fi

echo "=== INSTALLATION FINISHED! ==="
echo "Please restart your terminal or run 'source ~/.bashrc' to update your PATH."
echo "Open LunarVim by running: lvim"
echo "On the first interactive start, plugins will finish setting up."


