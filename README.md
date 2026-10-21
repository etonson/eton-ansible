# 🛠️ Eton Professional Dev Environment (Ansible Automation)

This project uses Ansible to automate the provisioning and configuration of a complete, professional development environment, including **Zsh (Oh My Zsh / Powerlevel10k)**, **WezTerm** with its configuration and font, and **Neovim (LazyVim)** along with its dependencies (compiler, linter, LSP tools).

This playbook is designed to fetch the latest configurations directly from remote GitHub repositories (without requiring local pre-cloned copies) and supports idempotency and auto-installation.

---

## 🗺️ Project Structure

```text
/home/sixson/eton-ansible/
├── ansible.cfg              # Ansible configuration file
├── inventory.yml            # Device inventory (defaults to localhost)
├── playbooks/
│   ├── workspace.yml        # Local workstation playbook
│   └── homelab.yml          # Homelab server playbook
├── bootstrap_ansible.sh     # One-click bootstrap script (installs Ansible & runs the playbook)
├── vars/
│   ├── default.yml          # Version locks, repository URLs, destinations, feature flags
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
* **(Optional)** Installs containerization tools `podman` and `podman-compose` (can be disabled in `vars/default.yml`).
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
ansible-playbook playbooks/workspace.yml --ask-become-pass
```

---

## ⚙️ Configuration & Customization
To customize your installation, modify [vars/default.yml](file:///home/sixson/eton-ansible/vars/default.yml):

* `install_bun`: Set to `true` or `false` to toggle the installation of Bun.
* `install_podman`: Set to `true` or `false` to toggle the installation of Podman.
* `dotfiles_repo` & `nvim_repo`: Set to customize your Git remote source URLs.

## Restoring SSH identities

Private keys are restored before any SSH-based Git checkout. Store them only in
an encrypted Ansible Vault file:

```bash
cp vars/vault.yml.example /tmp/vault-template.yml
ansible-vault create vars/vault.yml
```

Use the structure from the template, then commit the encrypted `vars/vault.yml`.
The bootstrap script detects an encrypted vault and asks for its password. It
never prints key contents (`no_log: true`). If no vault is configured, the
required GitHub identity must already exist on the machine.

## Custom workstation scripts

Run `./bootstrap_ansible.sh` to deploy the workspace, including the six
custom scripts versioned in `eton-dotfiles/bin/`. The `local_scripts` role
runs after the dotfiles checkout, installs Subversion and power-profiles-daemon
on Debian systems, and copies an explicit list of scripts to `/usr/local/bin`
with owner `root:root` and mode `0755`. Existing changed files are backed up.
It also deploys the user-scoped OpenSSL configuration for `svn-legacy`.
It does not execute the power commands during deployment.

`playbooks/homelab.yml` does not include this role, so it skips these scripts
and their associated dependencies/configuration. Existing files are left alone.
Installed binaries and package links are not collected from `/usr/local/bin`.

After editing scripts, commit and push dotfiles first, then update
`dotfiles_version` in `vars/default.yml` to that commit before deploying.
The standalone dotfiles bootstrap does not install these system commands.

## Reproducible versions

Repository commits and downloaded release tags are centralized in
`vars/default.yml`. Upgrade them deliberately instead of following `latest`.
After publishing a dotfiles change, update `dotfiles_version` to its deployed
commit SHA so restoration remains reproducible.
