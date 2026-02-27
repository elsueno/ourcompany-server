#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y python3 python3-apt git ansible

if sudo -n true 2>/dev/null; then
  ansible-playbook -i 'localhost,' -c local ops/ansible/site.yml
else
  ansible-playbook --ask-become-pass -i 'localhost,' -c local ops/ansible/site.yml
fi
