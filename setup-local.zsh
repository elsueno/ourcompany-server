#!/usr/bin/env zsh
set -euo pipefail

# SSH alias
SSH_NAME="peach"

# Remote users
REMOTE_ADMIN_USER="root"
REMOTE_USER="sven"

SSH_CONFIG="${HOME}/.ssh/config"

log() {
  print -r -- "==> $*"
}

ssh_admin() {
  ssh -t "${REMOTE_ADMIN_USER}@${SSH_NAME}" "$@"
}

ssh_user() {
  ssh -t "${REMOTE_USER}@${SSH_NAME}" "$@"
}

ensure_ssh_alias() {
  if [[ ! -f "${SSH_CONFIG}" ]]; then
    log "Missing SSH config at ${SSH_CONFIG}; add Host ${SSH_NAME} and retry"
    exit 1
  fi

  if grep -qE "^[[:space:]]*Host[[:space:]]+${SSH_NAME}$" "${SSH_CONFIG}"; then
    log "Found SSH alias ${SSH_NAME} in ${SSH_CONFIG}"
  else
    log "Missing SSH alias ${SSH_NAME} in ${SSH_CONFIG}; add it and retry"
    exit 1
  fi
}

log "Ensuring SSH alias ${SSH_NAME} in ${SSH_CONFIG}"
ensure_ssh_alias

log "Creating users on ${SSH_NAME} as ${REMOTE_ADMIN_USER}"
ssh_admin "id -u ${REMOTE_USER} >/dev/null 2>&1 || sudo adduser ${REMOTE_USER}"
ssh_admin "sudo usermod -aG sudo ${REMOTE_USER}"

log "Updating apt on ${SSH_NAME}"
ssh_admin "sudo apt update"

log "Verifying login as ${REMOTE_USER}"
ssh_user "whoami"

log "Copying public key: ${SSH_NAME}"
ssh-copy-id "${SSH_NAME}"
