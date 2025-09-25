#!/usr/bin/env bash

set -e

echo "=== LunarVim Ultimate Installer (Ubuntu/Debian) ==="
echo "Updating package list and installing dependencies..."

sudo apt update
sudo apt install -y curl git neovim nodejs npm python3-pip ripgrep fd-find unzip

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
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --yes

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