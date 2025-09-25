# LunarVim Ultimate Installer for Windows (PowerShell)
Write-Host "=== LunarVim Ultimate Installer (Windows) ===" -ForegroundColor Cyan

# Check for winget, fallback to choco if necessary
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget not found. Please install winget or Chocolatey first." -ForegroundColor Red
    exit 1
}

# Install dependencies
$pkgs = @("Neovim.Neovim", "Git.Git", "OpenJS.NodeJS.LTS", "Python.Python.3", "BurntSushi.ripgrep", "sharkdp.fd")
foreach ($pkg in $pkgs) {
    Write-Host "Installing $pkg ..."
    winget install --id $pkg -e --accept-source-agreements --accept-package-agreements
}

# Install Rust
if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Rust toolchain..."
    Invoke-WebRequest -Uri https://win.rustup.rs/ -OutFile rustup-init.exe
    Start-Process -Wait -FilePath .\rustup-init.exe -ArgumentList "-y"
    $env:Path += ";$env:USERPROFILE\.cargo\bin"
    Remove-Item .\rustup-init.exe
}

# Backup old configs
$dirs = @("$env:USERPROFILE\.config\nvim", "$env:USERPROFILE\.local\share\lunarvim", "$env:USERPROFILE\.config\lvim")
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Rename-Item $dir "$dir.backup.$([int][double]::Parse((Get-Date -UFormat %s)))"
    }
}

# Install LunarVim
Write-Host "Installing LunarVim..."
Invoke-Expression (Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.ps1).Content

# Add plugins to config.lua
$configDir = "$env:USERPROFILE\.config\lvim"
if (!(Test-Path $configDir)) { New-Item -ItemType Directory -Path $configDir | Out-Null }
@"
lvim.plugins = {
  {"nvim-tree/nvim-tree.lua"},
  {"nvim-telescope/telescope.nvim"},
  {"neovim/nvim-lspconfig"},
  {"github/copilot.vim"},
  {"Exafunction/codeium.vim"},
}
require("nvim-tree").setup{}
"@ | Set-Content -Path "$configDir\config.lua"

Write-Host "Testing lvim launch..."
Start-Process -NoNewWindow -FilePath "lvim.exe" -ArgumentList "+qall" -Wait

Write-Host "=== INSTALLATION FINISHED! ===" -ForegroundColor Green
Write-Host "Open LunarVim with: lvim"
Write-Host "First start will install plugins. See README for more info."