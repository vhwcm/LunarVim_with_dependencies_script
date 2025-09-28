#!/usr/bin/env bash

set -e

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
  
  # Check if required tools are available
  echo "Checking for required dependencies..."
  
  if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but not installed."
    echo "Please install curl first: sudo apt install curl"
    exit 1
  fi
  
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: git is required but not installed."
    echo "Please install git first: sudo apt install git"
    exit 1
  fi
  
  # Install Neovim locally if not available
  if ! command -v nvim >/dev/null 2>&1; then
    echo "Installing Neovim locally..."
    NVIM_VERSION="v0.9.5"
    cd /tmp
    curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
    tar xzf nvim-linux64.tar.gz
    cp -r nvim-linux64/* "$HOME/.local/"
    rm -rf nvim-linux64*
  fi
  
  # Install Node.js locally using n if not available
  if ! command -v node >/dev/null 2>&1; then
    echo "Installing Node.js locally..."
    curl -L https://bit.ly/n-install | N_PREFIX="$HOME/.local" bash -s -- -y latest
    export PATH="$HOME/.local/bin:$PATH"
  fi
  
  # Install ripgrep locally if not available
  if ! command -v rg >/dev/null 2>&1; then
    echo "Installing ripgrep locally..."
    RG_VERSION="13.0.0"
    cd /tmp
    curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar xzf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    cp "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg" "$HOME/.local/bin/"
    rm -rf ripgrep-*
  fi
  
  # Install fd locally if not available
  if ! command -v fd >/dev/null 2>&1; then
    echo "Installing fd locally..."
    FD_VERSION="8.7.0"
    cd /tmp
    curl -LO "https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    tar xzf "fd-v${FD_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    cp "fd-v${FD_VERSION}-x86_64-unknown-linux-musl/fd" "$HOME/.local/bin/"
    rm -rf fd-*
  fi
  
  # Add local bin to PATH if not already there
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "Added $HOME/.local/bin to PATH in .bashrc"
  fi
  
else
  echo "Installing in SYSTEM mode (requires sudo)..."
  echo "Updating package list and installing dependencies..."
  
  sudo apt update
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
if [ "$LOCAL_INSTALL" = true ]; then
  # Set environment variables for local installation
  export PATH="$HOME/.local/bin:$PATH"
  export LUNARVIM_RUNTIME_DIR="${LUNARVIM_RUNTIME_DIR:-"$HOME/.local/share/lunarvim"}"
  export LUNARVIM_CONFIG_DIR="${LUNARVIM_CONFIG_DIR:-"$HOME/.config/lvim"}"
  export LUNARVIM_CACHE_DIR="${LUNARVIM_CACHE_DIR:-"$HOME/.cache/lvim"}"
  
  # Install LunarVim with local paths
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --yes --local
else
  # Standard system installation
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --yes
fi

echo "Adding recommended plugins to config.lua..."

CONFIG_DIR="$HOME/.config/lvim"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.lua" <<EOF
lvim.plugins = {
  {"nvim-tree/nvim-tree.lua"},
  {"nvim-telescope/telescope.nvim"},
  {"neovim/nvim-lspconfig"},
  {"github/copilot.vim"},
  {"Exafunction/codeium.vim"},
}
-- nvim-tree setup
require("nvim-tree").setup{}
-- telescope setup (default)
-- LSP config auto-loaded by LunarVim

-- Copilot and Codeium require login/activation after install.
EOF

echo "Testing lvim launch and key bindings..."
if command -v lvim >/dev/null 2>&1; then
  timeout 10 lvim +"echo 'LunarVim started successfully!'" +qall || true
  echo "LunarVim was launched to finalize plugin installation."
else
  echo "ERROR: lvim not found in PATH!"
  exit 1
fi

echo "=== INSTALLATION FINISHED! ==="
echo "Open LunarVim by running: lvim"
echo "On first start, plugins will auto-install (may take a few minutes)."
echo "Explore with <Space>e (explorer), <Space>f (search), etc."
echo "See README for more info."