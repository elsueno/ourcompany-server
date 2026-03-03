#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y python3 python3-apt git ansible

if sudo -n true 2>/dev/null; then
  ANSIBLE_LOG="$(mktemp)"
  cleanup() {
    rm -f "$ANSIBLE_LOG"
  }
  trap cleanup EXIT

  set +e
  ansible-playbook -i 'localhost,' -c local ops/ansible/site.yml 2>&1 | tee "$ANSIBLE_LOG"
  ansible_status=${PIPESTATUS[0]}
  set -e

  if [ "$ansible_status" -eq 0 ]; then
    exit 0
  fi

  # Retry with become password only if non-interactive sudo is no longer available.
  if sudo -n true 2>/dev/null; then
    exit "$ansible_status"
  fi
fi

ansible-playbook --ask-become-pass -i 'localhost,' -c local ops/ansible/site.yml
