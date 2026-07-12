# 🛠️ Eton Professional Dev Environment (Ansible Automation)

This project uses Ansible to automate the provisioning and configuration of a complete, professional development environment, including **Zsh (Oh My Zsh / Powerlevel10k)**, **WezTerm** with its configuration and font, and **Neovim (LazyVim)** along with its dependencies (compiler, linter, LSP tools).

This playbook is designed to fetch the latest configurations directly from remote GitHub repositories (without requiring local pre-cloned copies) and supports idempotency and auto-installation.

---

## 🗺️ Project Structure

```text
/home/sixson/eton-ansible/
├── ansible.cfg              # Ansible configuration file
├── inventory.yml            # Device inventory (defaults to localhost)
├── playbook.yml             # Main Ansible playbook
├── bootstrap_ansible.sh     # One-click bootstrap script (installs Ansible & runs the playbook)
├── vars/
│   ├── default.yml          # Custom variables (GitHub repo URLs, destinations, Bun/Podman flags)
│   ├── secrets.yml          # Real personal information (git-ignored, never committed)
│   └── secrets.yml.example  # Template with placeholders for secrets
└── roles/
    ├── system/              # System packages & runtimes (APT packages, Podman, Bun)
    ├── git/                 # Deploys templated .gitconfig & .gitconfig-ginmao securely
    ├── zsh/                 # Clones dotfiles, provisions Zsh, Oh My Zsh framework & plugins
    ├── wezterm/             # Provisions WezTerm config and installs JetBrainsMono Nerd Font
    └── neovim/              # Installs Neovim binary, clones config & headless plugin sync
```

---

## ✨ Features & Role Details

### 1. `system` Role (System Dependencies)
* Updates `apt` cache.
* Installs core developer utility packages: `zsh`, `git`, `curl`, `wget`, `unzip`, `fonts-powerline`, `jq`, `libxml2-utils`, `build-essential`, `shellcheck`, `dos2unix`, `fontconfig`.
* **(Optional)** Installs containerization tool `podman` (can be disabled in `vars/default.yml`).
* **(Optional)** Installs Bun runtime environment `bun` (can be disabled in `vars/default.yml`).

### 2. `git` Role (Secure Git Configurations)
* Deploys `~/.gitconfig` and `~/.gitconfig-ginmao` to the home directory using Jinja2 templates.
* Supports Git Aliases (e.g., `lg`, `extract`, `savepoint`, `diff-da`) and custom workspace rules (`includeIf` for work directories like `~/ginmao-project/`).
* Obtains your personal name and email from `vars/secrets.yml` to keep them secure and off public remote repositories.

### 3. `zsh` Role (Zsh & Oh My Zsh)
* Clones the dotfiles repository `dotfiles_repo` (defaults to `git@github.com:etonson/eton-dotfiles.git`) to `~/.dotfiles`.
* Automatically backs up existing `~/.config/zsh` directory if it is not a symlink.
* Creates a symbolic link for `~/.config/zsh` pointing to `~/.dotfiles/zsh` to keep configurations version-controlled.
* Appends `export ZDOTDIR=$HOME/.config/zsh` to `~/.zshenv`.
* Installs `Oh My Zsh` framework.
* Clones/updates the latest version of the **Powerlevel10k** theme, **zsh-syntax-highlighting**, and **zsh-autosuggestions** plugins.
* Configures Zsh as the user's default system shell.

### 4. `wezterm` Role (WezTerm & Fonts)
* Automatically backs up existing `~/.config/wezterm` if it is not a symlink.
* Creates a symbolic link for `~/.config/wezterm` pointing to `~/.dotfiles/wezterm`.
* Downloads and installs the latest version of **JetBrainsMono Nerd Font** to `~/.local/share/fonts/`, and updates the font cache (`fc-cache`).

### 5. `neovim` Role (Neovim Setup)
* Checks if `nvim` is installed. If missing, downloads the latest stable release archive, extracts it to `/opt/nvim-linux64`, and creates a system-wide symlink at `/usr/local/bin/nvim`.
* Automatically backs up existing `~/.config/nvim` if it is not a Git repository.
* Clones `nvim_repo` (defaults to `git@github.com:etonson/eton-nvim.git`) directly into `~/.config/nvim`.
* Performs a headless plugin sync using `Lazy! sync` in Lazy.nvim.
* Performs a headless Mason tool installation using `MasonToolsInstall` to set up Linter/Formatter binaries (e.g. `shellcheck`, `shfmt`).

---

## 🔒 Managing Personal Information (Git Config)
To prevent committing your real name and email address to GitHub, this playbook loads them from a Git-ignored file:

1. Copy `vars/secrets.yml.example` to `vars/secrets.yml`:
   ```bash
   cp vars/secrets.yml.example vars/secrets.yml
   ```
2. Fill in your real details in `vars/secrets.yml`. Since `.gitignore` is configured to ignore `vars/secrets.yml`, your personal data will never be pushed to your repository.

---

## 🚀 Quick Start


### Option A: Using the Bootstrap Script (Recommended)
This script checks if `ansible-playbook` is installed on your system. If not, it will install it via `apt` and then execute the playbook. You will be prompted to enter your `sudo` password for tasks requiring administrator privileges.

```bash
# Run the bootstrap script
./bootstrap_ansible.sh
```

### Option B: Executing the Playbook Manually
If you already have Ansible installed, you can trigger the playbook directly:

```bash
ansible-playbook playbook.yml --ask-become-pass
```

---

## ⚙️ Configuration & Customization
To customize your installation, modify [vars/default.yml](file:///home/sixson/eton-ansible/vars/default.yml):

* `install_bun`: Set to `true` or `false` to toggle the installation of Bun.
* `install_podman`: Set to `true` or `false` to toggle the installation of Podman.
* `dotfiles_repo` & `nvim_repo`: Set to customize your Git remote source URLs.
