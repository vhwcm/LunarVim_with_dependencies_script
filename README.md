# Vim with dependencies install script 

One-command LunarVim installation for Ubuntu/Debian (bash) and Windows (PowerShell), including all dependencies and recommended plugins.

---

## Why this project?

I created this script because, based on my own experience, setting up a complete, modern Vim/Neovim environment was always time-consuming and often frustrating—especially when you want all the features working out-of-the-box. This installer takes care of everything for you: dependencies, plugin setup, configuration backup, and even verifying that all essential shortcuts work. Now, you can get a powerful IDE-like setup in your terminal in just one command, hassle-free!
#### Instalação local

Para instalar apenas para o usuário atual, utilize a flag `-l`:

```bash
./install.sh -l
```

Isso instalará o Vim e suas dependências localmente, sem afetar outros usuários do sistema.

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

```bash
bash <(curl -s https://raw.githubusercontent.com/vhwcm/lvim-ultimate-installer/main/install.sh)
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

---

> Enjoy a full-featured IDE inside your terminal, with all essential plugins pre-configured!