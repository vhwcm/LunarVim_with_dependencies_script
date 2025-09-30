# Vim with dependencies install script 

One-command LunarVim installation for Ubuntu/Debian (bash) and Windows (PowerShell), including all dependencies and recommended plugins.

---

## Why this project?

I created this script because, based on my own experience, setting up a complete, Vim/Neovim environment was always time-consuming and often frustrating—especially when you want all the features working out-of-the-box. This installer takes care of everything for you: dependencies, plugin setup, configuration backup, and even verifying that all essential shortcuts work.
## Instalação Local

Para instalar apenas para o usuário atual, sem necessidade de privilégios de administrador, utilize a flag `-l` ou `--local`:

```bash
./install.sh -l
```

**Vantagens da instalação local:**
- Não requer `sudo` ou privilégios de administrador
- Instala tudo em `~/.local/` (não afeta outros usuários)
- Adiciona automaticamente `~/.local/bin` ao seu PATH
- Ideal para ambientes onde você não tem acesso root

**Comandos para instalação local:**

```bash
# Opção 1: Download e execução direta
bash <(curl -s https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install.sh) -l

# Opção 2: Download primeiro, execução depois
curl -s https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install.sh -o install.sh
chmod +x install.sh
./install.sh -l
```

---

## Features

- Installs **LunarVim** and all required dependencies (Neovim, NodeJS, Rust, fd, ripgrep, etc.)
- Adds essential plugins:  
  - [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) (File explorer)  
  - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (Fuzzy finder/search)  
  - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) (LSP support)  
  - [github/copilot.vim](https://github.com/github/copilot.vim) (AI code assistant, optional)  
  - [Exafunction/codeium.vim](https://github.com/Exafunction/codeium.vim) (AI code assistant, optional)
- Backs up or removes conflicting configs safely
- Tests installation & confirms shortcut functionality
- Includes uninstall/test options

---

## Quick Start

### Ubuntu/Debian (bash)

**Instalação do sistema (requer sudo):**
```bash
bash <(curl -s https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install.sh)
```

**Instalação local (sem sudo):**
```bash
bash <(curl -s https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install.sh) -l
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install_win.ps1 | iex
```

---

## Plugins Included

- nvim-tree (file explorer): `<Space>e`
- telescope (search): `<Space>f`
- lspconfig (language features): auto-enabled
- copilot & codeium (AI - optional): see config instructions after install

---

## After Installation

- Open LunarVim with `lvim`
- First launch will install all plugins automatically (may take a few minutes)
- Press `<Space>` in NORMAL mode to see key mappings
- AI plugins require authentication/configuration (see plugin docs)

---

## Uninstall

See uninstall options in install script or simply remove LunarVim configs.
