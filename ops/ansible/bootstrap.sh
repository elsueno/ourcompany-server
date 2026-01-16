#!/usr/bin/env bash
set -euo pipefail

sudo apt update
sudo apt install -y python3 python3-apt git ansible

ansible-playbook -i 'localhost,' -c local ops/ansible/site.yml
