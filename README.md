# ourcompany server setup

Short notes on how to bootstrap a new host and provision a local user.

## setup-local.zsh (from your laptop)

- Requires a `Host strawberry` entry in `~/.ssh/config` and an accessible root login.
- Run `./setup-local.zsh` to create the `sven` user (if missing), add it to `sudo`, run `apt update`, verify login, and copy your SSH key with `ssh-copy-id`.

## ops/ (on the target host)

- `ops/ansible/bootstrap.sh` installs Ansible prerequisites and runs the local playbook.
- `ops/ansible/site.yml` provisions base packages, zsh + oh-my-zsh, docker group, lazygit/lazydocker, NVM + Node LTS, Codex CLI, and clones repos into `~/repos`.

Usage (on the target host):

```sh
./ops/ansible/bootstrap.sh
```

If the host requires a sudo password for privilege escalation, bootstrap may fail with:

```
sudo: a password is required
```

In that case, clear any old sudo cache and re-run bootstrap so it prompts for password:

```sh
sudo -k
./ops/ansible/bootstrap.sh
```

If you still need to force prompting from Ansible, run:

```sh
ansible-playbook --ask-become-pass -i 'localhost,' -c local ops/ansible/site.yml
```

Copy ops to the remote host (from your laptop):

```sh  { name=scp-ops }
scp -r ops sven@strawberry:~/ops
```
