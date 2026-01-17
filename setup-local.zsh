#!/usr/bin/env zsh
set -euo pipefail

# Remote server and SSH alias
REMOTE_SERVER="217.160.79.77"
SSH_NAME="lychee"

# Remote users
REMOTE_ADMIN_USER="ourcompany"
REMOTE_USER="sven"

SSH_CONFIG="${HOME}/.ssh/config"

log() {
  print -r -- "==> $*"
}

ssh_admin() {
  ssh -t "${REMOTE_ADMIN_USER}@${REMOTE_SERVER}" "$@"
}

ssh_user() {
  ssh -t "${REMOTE_USER}@${REMOTE_SERVER}" "$@"
}

ensure_ssh_config() {
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  if [[ ! -f "${SSH_CONFIG}" ]]; then
    touch "${SSH_CONFIG}"
  fi

  if grep -qE "^[[:space:]]*Host[[:space:]]+${SSH_NAME}$" "${SSH_CONFIG}"; then
    log "SSH config already has Host ${SSH_NAME}; skipping"
  else
    cat >> "${SSH_CONFIG}" <<EOF
Host ${SSH_NAME}
  HostName ${REMOTE_SERVER}
  User ${REMOTE_USER}
EOF
  fi

  chmod 600 "${SSH_CONFIG}"
}

log "Creating users on ${REMOTE_SERVER} as ${REMOTE_ADMIN_USER}"
ssh_admin "id -u ${REMOTE_USER} >/dev/null 2>&1 || sudo adduser ${REMOTE_USER}"
ssh_admin "sudo usermod -aG sudo ${REMOTE_USER}"

log "Updating apt on ${REMOTE_SERVER}"
ssh_admin "sudo apt update"

log "Verifying login as ${REMOTE_USER}"
ssh_user "whoami"

log "Ensuring SSH alias ${SSH_NAME} in ${SSH_CONFIG}"
ensure_ssh_config

log "Opening SSH session: ${SSH_NAME}"
ssh "${SSH_NAME}"
