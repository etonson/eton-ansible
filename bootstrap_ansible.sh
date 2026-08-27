#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$REPO_DIR"

# ANSI escape codes for coloring
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Bootstrapping Ansible development environment...${NC}"

# 1. Install Ansible
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${YELLOW}📦 Ansible not found. Installing...${NC}"
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get update
        sudo apt-get install -y ansible
    else
        echo -e "${RED}❌ Unsupported package manager. Please install Ansible manually.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Ansible is already installed.${NC}"
fi

# 2. Run Ansible Playbook
echo -e "${BLUE}🎬 Running Ansible Playbook...${NC}"
VAULT_ARGS=()
if [[ -f vars/vault.yml ]] && head -n 1 vars/vault.yml | grep -q '^\$ANSIBLE_VAULT;'; then
    VAULT_ARGS=(--ask-vault-pass)
fi
ansible-playbook playbooks/workspace.yml --ask-become-pass "${VAULT_ARGS[@]}" "$@"
